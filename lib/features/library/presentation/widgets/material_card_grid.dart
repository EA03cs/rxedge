import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/material_item_entity.dart';

/// Organic wave clipper for the bottom edge of the material card thumbnail
class _CardWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 12);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height - 24,
      size.width,
      size.height - 6,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Grid Item Card for Resource Library / Marketing Hub matching reference design
class MaterialCardGrid extends StatelessWidget {
  final MaterialItemEntity item;
  final bool isOffline;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onMoreActions;

  const MaterialCardGrid({
    super.key,
    required this.item,
    required this.isOffline,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onDownload,
    required this.onCancelDownload,
    required this.onMoreActions,
  });

  IconData _getTypeIcon(MaterialFileType type) {
    switch (type) {
      case MaterialFileType.pdf:
        return LucideIcons.fileText;
      case MaterialFileType.image:
        return LucideIcons.image;
      case MaterialFileType.edetailSlides:
        return LucideIcons.presentation;
    }
  }

  String _formatDate(BuildContext context, DateTime dt) {
    return DateFormat('MMM d, y').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final l10n = context.l10n;

    // In offline mode, items that are not downloaded are disabled
    final isVisiblyDisabled = isOffline && !item.isDownloaded;

    return Opacity(
      opacity: isVisiblyDisabled ? 0.45 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isVisiblyDisabled
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.requiresDownload,
                          style: TextStyle(color: colors.surface),
                        ),
                        backgroundColor: colors.textPrimary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                : onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Image Banner with Organic Wave
                SizedBox(
                  height: 104.0,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Clipped Background Image
                      Positioned.fill(
                        child: ClipPath(
                          clipper: _CardWaveClipper(),
                          child: (item.thumbnailUrl ?? item.fileUrl)?.trim().isNotEmpty == true
                              ? RxNetworkImage(
                                  imageUrl: item.thumbnailUrl ?? item.fileUrl,
                                  width: double.infinity,
                                  height: 104.0,
                                  fit: BoxFit.cover,
                                  fallbackIcon: _getTypeIcon(item.fileType),
                                )
                              : Container(
                                  color: const Color(0xFFE0F2FE),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _getTypeIcon(item.fileType),
                                    size: 32.0,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                        ),
                      ),

                      // Pill Badge (Top Left)
                      PositionedDirectional(
                        top: 8.0,
                        start: 8.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7.0,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4.0,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            item.badge == MaterialBadge.updated
                                ? 'UPDATED'
                                : (item.badge == MaterialBadge.newRelease
                                    ? 'NEW'
                                    : (item.fileUrl == null || item.fileUrl!.trim().isEmpty
                                        ? 'قريباً'
                                        : (item.quarter != null
                                            ? 'Q${item.quarter} ${item.year ?? ''}'.trim()
                                            : 'NEW'))),
                            style: const TextStyle(
                              color: Color(0xFF0284C7),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),

                      // Bookmark / Favorite Toggle Button (Top Right)
                      PositionedDirectional(
                        top: 8.0,
                        end: 8.0,
                        child: GestureDetector(
                          onTap: onToggleFavorite,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 30.0,
                            height: 30.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.90),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              item.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                              size: 17.0,
                              color: item.isFavorite
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),

                      // Offline Downloaded Indicator
                      if (item.isDownloaded)
                        PositionedDirectional(
                          bottom: 12.0,
                          start: 8.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: colors.successSoft,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.check,
                                  size: 10.0,
                                  color: colors.success,
                                ),
                                const SizedBox(width: 2.0),
                                Text(
                                  l10n.offlineStatusBadge,
                                  style: TextStyle(
                                    color: colors.success,
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Online Only badge when offline
                      if (isVisiblyDisabled)
                        PositionedDirectional(
                          bottom: 12.0,
                          start: 8.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.cloudOff,
                                  size: 10.0,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 3.0),
                                Text(
                                  l10n.onlineOnlyStatusBadge,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. Card Content Below Wave
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3.0),

                        // Subtitle / Description
                        Expanded(
                          child: Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 11.0,
                              color: Color(0xFF64748B),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Meta Row: File icon + Size + Date + More
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.fileText,
                              size: 13.0,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              item.formattedSize,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              ' • ',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10.0,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _formatDate(context, item.updatedAt),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: onMoreActions,
                              behavior: HitTestBehavior.opaque,
                              child: const Icon(
                                LucideIcons.moreHorizontal,
                                size: 16.0,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),

                        // Downloading Progress Bar
                        if (item.isDownloading) ...[
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              Expanded(
                                child: ProgressBar(
                                  value: item.downloadProgress,
                                  height: 3.5,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              GestureDetector(
                                onTap: onCancelDownload,
                                child: Icon(
                                  LucideIcons.x,
                                  size: 12.0,
                                  color: colors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
