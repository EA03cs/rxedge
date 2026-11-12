import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/rx_network_image.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/material_item_entity.dart';

/// Grid Item Card for Resource Library
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
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMd(locale).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    // In offline mode, items that are not downloaded are disabled
    final isVisiblyDisabled = isOffline && !item.isDownloaded;

    return Opacity(
      opacity: isVisiblyDisabled ? 0.45 : 1.0,
      child: AppCard(
        padding: EdgeInsetsDirectional.zero,
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
            // 1. Top Thumbnail Box
            Container(
              height: 104.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(RxRadii.card),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: colors.border,
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  if ((item.thumbnailUrl ??
                          (item.fileType == MaterialFileType.image
                              ? item.fileUrl
                              : null))
                      ?.trim()
                      .isNotEmpty ==
                      true)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(RxRadii.card),
                        ),
                        child: RxNetworkImage(
                          imageUrl: item.thumbnailUrl ?? item.fileUrl,
                          width: double.infinity,
                          height: 104.0,
                          fit: BoxFit.cover,
                          fallbackIcon: _getTypeIcon(item.fileType),
                        ),
                      ),
                    )
                  else
                    // Centered Type Icon & Tag
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(item.fileType),
                            size: 32.0,
                            color: colors.primary,
                          ),
                          const SizedBox(height: RxSpacing.s4),
                          Text(
                            item.fileType == MaterialFileType.edetailSlides
                                ? l10n.slidesCountLabel(item.slides.length)
                                : l10n.pagesCountLabel(item.pageCount),
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Offline Available Indicator
                  if (item.isDownloaded)
                    PositionedDirectional(
                      top: RxSpacing.s8,
                      start: RxSpacing.s8,
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: RxSpacing.s6,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.successSoft,
                          borderRadius: RxRadii.borderBadge,
                          border: Border.all(
                            color: colors.success.withValues(alpha: 0.3),
                            width: RxShadows.hairlineBorderWidth,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.check,
                              size: 11.0,
                              color: colors.success,
                            ),
                            const SizedBox(width: RxSpacing.s2),
                            Text(
                              l10n.offlineStatusBadge,
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.success,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Favorite Toggle Button
                  PositionedDirectional(
                    top: 2.0,
                    end: 2.0,
                    child: IconButton(
                      icon: Icon(
                        item.isFavorite ? LucideIcons.bookmark : LucideIcons.bookmark,
                        size: 18.0,
                        color: item.isFavorite ? colors.primary : colors.textTertiary,
                      ),
                      tooltip: item.isFavorite ? l10n.actionUnfavorite : l10n.actionFavorite,
                      onPressed: onToggleFavorite,
                      constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                    ),
                  ),

                  // If offline and disabled, show lock badge
                  if (isVisiblyDisabled)
                    PositionedDirectional(
                      bottom: RxSpacing.s6,
                      start: RxSpacing.s8,
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: RxSpacing.s6,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: RxRadii.borderBadge,
                          border: Border.all(
                            color: colors.border,
                            width: RxShadows.hairlineBorderWidth,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.cloudOff,
                              size: 10.0,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: RxSpacing.s4),
                            Text(
                              l10n.onlineOnlyStatusBadge,
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Card Content
            Padding(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Tag & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.badge == MaterialBadge.newRelease)
                        StatusBadge(
                          label: l10n.badgeNew,
                          variant: StatusBadgeVariant.info,
                        )
                      else if (item.badge == MaterialBadge.updated)
                        StatusBadge(
                          label: l10n.badgeUpdated,
                          variant: StatusBadgeVariant.neutral,
                        ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s4),

                  // Title
                  Text(
                    item.title,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      height: 1.3,
                      fontSize: 12.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: RxSpacing.s8),

                  // File size & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.formattedSize} • ${_formatDate(context, item.updatedAt)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                      InkWell(
                        onTap: onMoreActions,
                        borderRadius: RxRadii.borderBadge,
                        child: Icon(
                          LucideIcons.moreHorizontal,
                          size: 16.0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Downloading progress bar if active
                  if (item.isDownloading) ...[
                    const SizedBox(height: RxSpacing.s6),
                    Row(
                      children: [
                        Expanded(
                          child: ProgressBar(
                            value: item.downloadProgress,
                            height: 4.0,
                          ),
                        ),
                        const SizedBox(width: RxSpacing.s6),
                        InkWell(
                          onTap: onCancelDownload,
                          child: Icon(
                            LucideIcons.x,
                            size: 13.0,
                            color: colors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
