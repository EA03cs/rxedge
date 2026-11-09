import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/material_item_entity.dart';

/// List Item Card for Resource Library
class MaterialCardList extends StatelessWidget {
  final MaterialItemEntity item;
  final bool isOffline;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onMoreActions;

  const MaterialCardList({
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

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final isVisiblyDisabled = isOffline && !item.isDownloaded;

    return Opacity(
      opacity: isVisiblyDisabled ? 0.45 : 1.0,
      child: AppCard(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Thumbnail / File Type Icon Box
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: RxRadii.borderBadge,
                border: Border.all(
                  color: colors.border,
                  width: RxShadows.hairlineBorderWidth,
                ),
              ),
              child: Center(
                child: Icon(
                  _getTypeIcon(item.fileType),
                  size: 22.0,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: RxSpacing.s12),

            // 2. Middle Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        item.productName,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.0,
                        ),
                      ),
                      if (item.badge == MaterialBadge.newRelease) ...[
                        const SizedBox(width: RxSpacing.s6),
                        StatusBadge(
                          label: l10n.badgeNew,
                          variant: StatusBadgeVariant.info,
                        ),
                      ] else if (item.badge == MaterialBadge.updated) ...[
                        const SizedBox(width: RxSpacing.s6),
                        StatusBadge(
                          label: l10n.badgeUpdated,
                          variant: StatusBadgeVariant.neutral,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s2),
                  Text(
                    item.title,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      height: 1.25,
                      fontSize: 13.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: RxSpacing.s4),
                  Row(
                    children: [
                      Text(
                        '${item.formattedSize} • ${_formatDate(item.updatedAt)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 11.0,
                        ),
                      ),
                      if (item.isDownloaded) ...[
                        const SizedBox(width: RxSpacing.s8),
                        Icon(
                          LucideIcons.check,
                          size: 12.0,
                          color: colors.success,
                        ),
                        const SizedBox(width: RxSpacing.s2),
                        Text(
                          'Offline',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.success,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: RxSpacing.s8),

            // 3. End Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.isDownloading)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22.0,
                        height: 22.0,
                        child: CircularProgressIndicator(
                          value: item.downloadProgress,
                          strokeWidth: 2.5,
                          color: colors.primary,
                          backgroundColor: colors.surfaceMuted,
                        ),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.x, size: 16.0, color: colors.error),
                        tooltip: l10n.actionCancelDownload,
                        onPressed: onCancelDownload,
                        constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
                      ),
                    ],
                  )
                else if (!item.isDownloaded && !isOffline)
                  IconButton(
                    icon: Icon(
                      LucideIcons.downloadCloud,
                      size: 18.0,
                      color: colors.textSecondary,
                    ),
                    tooltip: l10n.actionDownload,
                    onPressed: onDownload,
                    constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                  ),
                IconButton(
                  icon: Icon(
                    item.isFavorite ? LucideIcons.bookmark : LucideIcons.bookmark,
                    size: 18.0,
                    color: item.isFavorite ? colors.primary : colors.textTertiary,
                  ),
                  tooltip: item.isFavorite ? l10n.actionUnfavorite : l10n.actionFavorite,
                  onPressed: onToggleFavorite,
                  constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.moreVertical,
                    size: 16.0,
                    color: colors.textSecondary,
                  ),
                  onPressed: onMoreActions,
                  constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
