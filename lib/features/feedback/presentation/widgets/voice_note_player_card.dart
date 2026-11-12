import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/network/url_resolver.dart';
import '../../../../core/storage/local_file_helper.dart';

/// Interactive voice note playback card supporting both local recorded files
/// (pending/offline) and remote uploaded URLs.
///
/// Lazily initializes [AudioPlayer] only when playback is requested so pure
/// widget tests without native audio channels remain completely safe.
class VoiceNotePlayerCard extends StatefulWidget {
  final String voiceSource;
  final VoidCallback? onRemove;
  final String? durationLabel;

  const VoiceNotePlayerCard({
    super.key,
    required this.voiceSource,
    this.onRemove,
    this.durationLabel,
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

  @override
  void dispose() {
    _stateSub?.cancel();
    _completeSub?.cancel();
    try {
      _player?.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      if (_player == null) {
        final player = AudioPlayer();
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
      } else {
        final resolved = UrlResolver.resolve(widget.voiceSource) ?? widget.voiceSource;
        await _player!.play(UrlSource(resolved));
      }
    } catch (_) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تعذر تشغيل التسجيل الصوتي حالياً'
                : 'Unable to play voice note right now.',
          ),
        ),
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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: RxSpacing.s12,
        vertical: RxSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: RxRadii.borderInput,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.35),
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
                  _isPlaying
                      ? (isArabic ? 'جاري تشغيل التسجيل الصوتي...' : 'Playing voice note...')
                      : l10n.voiceAttachedLabel,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
                if (widget.durationLabel != null) ...[
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
