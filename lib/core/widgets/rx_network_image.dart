import 'package:flutter/material.dart';
import '../components/skeleton_box.dart';
import '../network/url_resolver.dart';
import '../storage/local_file_helper.dart';
import '../theme/theme.dart';

/// Displays a local or HTTP/relative backend image cleanly with loading skeleton,
/// responsive fit, and an on-brand fallback surface if offline or unreachable.
class RxNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String? localFilePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final Color? fallbackBackground;

  const RxNetworkImage({
    super.key,
    required this.imageUrl,
    this.localFilePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.medical_information_outlined,
    this.fallbackColor,
    this.fallbackBackground,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final resolved = UrlResolver.resolve(imageUrl);
    final Widget fallback = Container(
      width: width,
      height: height,
      color: fallbackBackground ?? colors.primarySoft,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        color: fallbackColor ?? colors.primary,
        size: (height != null && height! < 72) ? 24 : 36,
      ),
    );

    final diskPath = localFileExists(localFilePath)
        ? localFilePath
        : (localFileExists(imageUrl) ? imageUrl : null);

    if (diskPath != null) {
      return _wrapClip(
        buildLocalFileImage(
          diskPath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: () => _buildNetworkOrFallback(resolved, fallback),
        ),
      );
    }

    return _wrapClip(_buildNetworkOrFallback(resolved, fallback));
  }

  Widget _buildNetworkOrFallback(String? resolved, Widget fallback) {
    if (resolved == null) {
      return fallback;
    }

    return Image.network(
      resolved,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SkeletonBox(
          width: width,
          height: height ?? 120,
          borderRadius: borderRadius,
        );
      },
      errorBuilder: (_, _, _) => fallback,
    );
  }

  Widget _wrapClip(Widget child) {
    if (borderRadius == null) return child;
    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }
}
