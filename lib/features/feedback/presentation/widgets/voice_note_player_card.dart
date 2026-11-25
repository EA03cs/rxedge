import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/url_resolver.dart';
import '../../../../core/storage/local_file_helper.dart';

/// Interactive voice note playback card supporting both local recorded files
/// (pending/offline) and remote uploaded URLs.
///
/// Remote voice notes are downloaded via the authenticated [Dio] client
/// (which attaches Bearer JWT only to the API host and refreshes on 401) into a
/// temporary file in `getTemporaryDirectory()`, played via [DeviceFileSource],
/// and cleaned up on dispose. Lazily initializes [AudioPlayer] only when
/// playback is requested so pure widget tests without native audio channels
/// remain completely safe.
class VoiceNotePlayerCard extends StatefulWidget {
  final String voiceSource;
  final VoidCallback? onRemove;
  final String? durationLabel;
  final Dio? dioClient;
  final AudioPlayer Function()? playerBuilder;
  final Future<String?> Function(List<int> bytes, {String extension})?
      tempFileWriter;

  const VoiceNotePlayerCard({
    super.key,
    required this.voiceSource,
    this.onRemove,
    this.durationLabel,
    this.dioClient,
    this.playerBuilder,
    this.tempFileWriter,
  });

  @override
  State<VoiceNotePlayerCard> createState() => _VoiceNotePlayerCardState();
}

class _VoiceNotePlayerCardState extends State<VoiceNotePlayerCard> {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;
  bool _isPlaying = false;
  bool _isBusy = false;
  String? _tempFilePath;
  String? _errorMessage;

  @override
  void didUpdateWidget(covariant VoiceNotePlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voiceSource != widget.voiceSource) {
      try {
        _player?.stop();
      } catch (_) {}
      final oldTemp = _tempFilePath;
      _tempFilePath = null;
      _isPlaying = false;
      _errorMessage = null;
      if (oldTemp != null) {
        unawaited(deleteLocalFile(oldTemp));
      }
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _completeSub?.cancel();
    try {
      _player?.dispose();
    } catch (_) {}
    final tempPath = _tempFilePath;
    _tempFilePath = null;
    if (tempPath != null) {
      unawaited(deleteLocalFile(tempPath));
    }
    super.dispose();
  }

  Dio _resolveDioClient(String resolvedUrl) {
    if (widget.dioClient != null) return widget.dioClient!;
    if (UrlResolver.isApiHost(resolvedUrl)) {
      try {
        final container = ProviderScope.containerOf(context, listen: false);
        return container.read(dioClientProvider);
      } catch (_) {}
    }
    return Dio();
  }

  String _extractAudioExtension(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return 'm4a';
    final ext = path.substring(dotIndex + 1).toLowerCase();
    if (ext.length > 5 || !RegExp(r'^[a-z0-9]+$').hasMatch(ext)) {
      return 'm4a';
    }
    return ext;
  }

  Future<void> _togglePlay() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      if (_player == null) {
        final player = widget.playerBuilder?.call() ?? AudioPlayer();
        _stateSub = player.onPlayerStateChanged.listen((state) {
          if (!mounted) return;
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        });
        _completeSub = player.onPlayerComplete.listen((_) {
          if (!mounted) return;
          setState(() {
            _isPlaying = false;
          });
        });
        _player = player;
      }

      if (_isPlaying) {
        await _player!.pause();
        return;
      }

      if (localFileExists(widget.voiceSource)) {
        await _player!.play(DeviceFileSource(widget.voiceSource));
      } else if (!kIsWeb &&
          _tempFilePath != null &&
          localFileExists(_tempFilePath)) {
        await _player!.play(DeviceFileSource(_tempFilePath!));
      } else {
        final resolved =
            UrlResolver.resolve(widget.voiceSource) ?? widget.voiceSource;
        final dio = _resolveDioClient(resolved);
        final response = await dio.get<List<int>>(
          resolved,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          throw const FormatException('Voice note file is empty.');
        }

        if (kIsWeb) {
          await _player!.play(BytesSource(Uint8List.fromList(bytes)));
        } else {
          final ext = _extractAudioExtension(resolved);
          final tempPath = widget.tempFileWriter != null
              ? await widget.tempFileWriter!(bytes, extension: ext)
              : await saveTempMediaBytes(
                  bytes,
                  prefix: 'rxedge_voice',
                  extension: ext,
                );
          if (tempPath == null || tempPath.isEmpty) {
            throw StateError('Unable to cache temporary voice note file.');
          }
          _tempFilePath = tempPath;
          await _player!.play(DeviceFileSource(tempPath));
        }
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final statusCode = e.response?.statusCode;
      final msg = switch (statusCode) {
        401 => 'Authentication required to play voice note (401).',
        403 => 'You do not have permission to play this voice note (403).',
        _ => 'Unable to play voice note right now.',
      };
      setState(() => _errorMessage = msg);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (_) {
      if (!mounted) return;
      const msg = 'Unable to play voice note right now.';
      setState(() => _errorMessage = msg);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RxSpacing.s12,
        vertical: RxSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: RxRadii.borderInput,
        border: Border.all(
          color: _errorMessage != null
              ? colors.error.withValues(alpha: 0.45)
              : colors.primary.withValues(alpha: 0.35),
          width: RxShadows.hairlineBorderWidth,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _togglePlay,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 34.0,
              height: 34.0,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: _isBusy
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: colors.surface,
                      ),
                    )
                  : Icon(
                      _isPlaying ? LucideIcons.pause : LucideIcons.play,
                      size: 16.0,
                      color: colors.surface,
                    ),
            ),
          ),
          const SizedBox(width: RxSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isPlaying ? 'Playing voice note...' : l10n.voiceAttachedLabel,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    _errorMessage!,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.error,
                      fontSize: 11.0,
                    ),
                  ),
                ] else if (widget.durationLabel != null) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    widget.durationLabel!,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.onRemove != null)
            IconButton(
              icon: Icon(LucideIcons.x, size: 16.0, color: colors.textSecondary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28.0, minHeight: 28.0),
              onPressed: () {
                try {
                  _player?.stop();
                } catch (_) {}
                widget.onRemove?.call();
              },
            ),
        ],
      ),
    );
  }
}
