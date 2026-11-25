import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/skeleton_box.dart';
import '../network/dio_client.dart';
import '../network/url_resolver.dart';
import '../storage/local_file_helper.dart';
import '../theme/theme.dart';

/// Displays a local or HTTP/relative backend image cleanly with loading skeleton,
/// responsive fit, and an on-brand fallback surface if offline or unreachable.
///
/// For URLs hosted on the configured API host, fetches bytes using the
/// authenticated [Dio] client (attaching Bearer JWT only to the API host and
/// transparently refreshing on 401), and displays a clear non-crashing error
/// placeholder on 401/403 responses.
class RxNetworkImage extends StatefulWidget {
  final String? imageUrl;
  final String? localFilePath;
  final String? fallbackAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final Color? fallbackBackground;
  final Map<String, String>? headers;
  final String? authToken;
  final Dio? dioClient;

  const RxNetworkImage({
    super.key,
    required this.imageUrl,
    this.localFilePath,
    this.fallbackAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.medical_information_outlined,
    this.fallbackColor,
    this.fallbackBackground,
    this.headers,
    this.authToken,
    this.dioClient,
  });

  @override
  State<RxNetworkImage> createState() => _RxNetworkImageState();
}

class _RxNetworkImageState extends State<RxNetworkImage> {
  static const Map<String, String> _defaultHeaders = <String, String>{
    'User-Agent': 'Mozilla/5.0 (Linux; Android 14) RxEdge/1.0',
  };

  String? _activeUrl;
  Uint8List? _bytes;
  bool _isLoading = false;
  bool _hasError = false;
  int? _errorStatusCode;
  bool _useNetworkImageFallback = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncImageSource();
  }

  @override
  void didUpdateWidget(covariant RxNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.localFilePath != widget.localFilePath ||
        oldWidget.authToken != widget.authToken ||
        oldWidget.dioClient != widget.dioClient) {
      _activeUrl = null;
      _syncImageSource();
    }
  }

  Dio? _tryReadDioClient() {
    if (widget.dioClient != null) return widget.dioClient;
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      return container.read(dioClientProvider);
    } catch (_) {
      return null;
    }
  }

  void _syncImageSource() {
    final raw = widget.imageUrl;
    if (raw != null && raw.startsWith('assets/')) {
      _resetFetchState();
      return;
    }

    final isWebOrServerUrl = (raw?.startsWith('http://') ?? false) ||
        (raw?.startsWith('https://') ?? false) ||
        (raw?.startsWith('/') ?? false);

    final diskPath = localFileExists(widget.localFilePath)
        ? widget.localFilePath
        : (!isWebOrServerUrl && localFileExists(raw) ? raw : null);

    if (diskPath != null) {
      _resetFetchState();
      return;
    }

    final resolved = UrlResolver.resolve(raw);
    if (resolved == null || resolved.trim().isEmpty) {
      _resetFetchState();
      return;
    }

    if (!UrlResolver.isApiHost(resolved)) {
      _resetFetchState();
      return;
    }

    if (_activeUrl == resolved) return;

    final dio = _tryReadDioClient();
    if (dio == null) {
      _activeUrl = resolved;
      _bytes = null;
      _isLoading = false;
      _hasError = false;
      _errorStatusCode = null;
      _useNetworkImageFallback = true;
      return;
    }

    _fetchProtectedImage(resolved, dio);
  }

  void _resetFetchState() {
    _activeUrl = null;
    _bytes = null;
    _isLoading = false;
    _hasError = false;
    _errorStatusCode = null;
    _useNetworkImageFallback = false;
  }

  Future<void> _fetchProtectedImage(String resolved, Dio dio) async {
    _activeUrl = resolved;
    _bytes = null;
    _isLoading = true;
    _hasError = false;
    _errorStatusCode = null;
    _useNetworkImageFallback = false;

    try {
      final authHeaders = buildProtectedMediaHeaders(resolved, widget.authToken);
      final mergedHeaders = <String, String>{
        ...?authHeaders,
        ...?widget.headers,
      };
      final response = await dio.get<List<int>>(
        resolved,
        options: Options(
          responseType: ResponseType.bytes,
          headers: mergedHeaders.isEmpty ? null : mergedHeaders,
        ),
      );

      if (!mounted || _activeUrl != resolved) return;

      final data = response.data;
      if (data == null || data.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorStatusCode = response.statusCode;
        });
        return;
      }

      setState(() {
        _bytes = Uint8List.fromList(data);
        _isLoading = false;
        _hasError = false;
        _errorStatusCode = null;
      });
    } on DioException catch (e) {
      if (!mounted || _activeUrl != resolved) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorStatusCode = e.response?.statusCode;
      });
    } catch (_) {
      if (!mounted || _activeUrl != resolved) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorStatusCode = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final resolved = UrlResolver.resolve(widget.imageUrl);
    final Widget iconFallback = Container(
      width: widget.width,
      height: widget.height,
      color: widget.fallbackBackground ?? colors.primarySoft,
      alignment: Alignment.center,
      child: Icon(
        widget.fallbackIcon,
        color: widget.fallbackColor ?? colors.primary,
        size: (widget.height != null && widget.height! < 72) ? 24 : 36,
      ),
    );

    final Widget effectiveFallback =
        (widget.fallbackAsset != null && widget.fallbackAsset!.trim().isNotEmpty)
            ? Image.asset(
                widget.fallbackAsset!,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                errorBuilder: (_, _, _) => iconFallback,
              )
            : iconFallback;

    final isWebOrServerUrl = (widget.imageUrl?.startsWith('http://') ?? false) ||
        (widget.imageUrl?.startsWith('https://') ?? false) ||
        (widget.imageUrl?.startsWith('/') ?? false);

    if (widget.imageUrl != null && widget.imageUrl!.startsWith('assets/')) {
      return _wrapClip(
        Image.asset(
          widget.imageUrl!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (_, _, _) => effectiveFallback,
        ),
      );
    }

    final diskPath = localFileExists(widget.localFilePath)
        ? widget.localFilePath
        : (!isWebOrServerUrl && localFileExists(widget.imageUrl)
            ? widget.imageUrl
            : null);

    if (diskPath != null) {
      return _wrapClip(
        buildLocalFileImage(
          diskPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: () =>
              _buildNetworkOrFallback(context, resolved, effectiveFallback),
        ),
      );
    }

    return _wrapClip(
      _buildNetworkOrFallback(context, resolved, effectiveFallback),
    );
  }

  Widget _buildNetworkOrFallback(
    BuildContext context,
    String? resolved,
    Widget fallback,
  ) {
    if (resolved == null || resolved.trim().isEmpty) {
      return fallback;
    }

    if (UrlResolver.isApiHost(resolved) && !_useNetworkImageFallback) {
      if (_isLoading) {
        return SkeletonBox(
          width: widget.width,
          height: widget.height ?? 120,
          borderRadius: widget.borderRadius,
        );
      }

      if (_hasError) {
        if (_errorStatusCode == 401 || _errorStatusCode == 403) {
          return _buildAuthErrorPlaceholder(
            context,
            _errorStatusCode!,
            fallback,
          );
        }
        return fallback;
      }

      if (_bytes != null) {
        return Image.memory(
          _bytes!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => fallback,
        );
      }

      return fallback;
    }

    final authHeaders = buildProtectedMediaHeaders(resolved, widget.authToken);
    final mergedHeaders = <String, String>{
      ..._defaultHeaders,
      ...?authHeaders,
      ...?widget.headers,
    };

    return Image.network(
      resolved,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      headers: mergedHeaders,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SkeletonBox(
          width: widget.width,
          height: widget.height ?? 120,
          borderRadius: widget.borderRadius,
        );
      },
      errorBuilder: (context, error, _) {
        if (error is NetworkImageLoadException &&
            (error.statusCode == 401 || error.statusCode == 403)) {
          return _buildAuthErrorPlaceholder(
            context,
            error.statusCode,
            fallback,
          );
        }
        return fallback;
      },
    );
  }

  Widget _buildAuthErrorPlaceholder(
    BuildContext context,
    int statusCode,
    Widget fallback,
  ) {
    final canShowMessage = (widget.height == null || widget.height! >= 110) &&
        (widget.width == null || widget.width! >= 140);
    if (!canShowMessage) {
      return fallback;
    }

    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final message = statusCode == 403
        ? 'Access denied: you do not have permission to view this image (403).'
        : 'Authentication required to load protected image (401).';

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            color: colors.error,
            size: 28.0,
          ),
          const SizedBox(height: RxSpacing.s8),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapClip(Widget child) {
    if (widget.borderRadius == null) return child;
    return ClipRRect(
      borderRadius: widget.borderRadius!,
      child: child,
    );
  }
}
