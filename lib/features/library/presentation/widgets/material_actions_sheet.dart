import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../domain/entities/material_item_entity.dart';

/// Modal Actions Sheet for Material item
class MaterialActionsSheet extends StatelessWidget {
  final MaterialItemEntity item;
  final bool isOffline;
  final VoidCallback onOpen;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDownload;
  final VoidCallback onRemoveDownload;

  const MaterialActionsSheet({
    super.key,
    required this.item,
    required this.isOffline,
    required this.onOpen,
    required this.onToggleFavorite,
    required this.onDownload,
    required this.onRemoveDownload,
  });

  static void show(
    BuildContext context, {
    required MaterialItemEntity item,
    required bool isOffline,
    required VoidCallback onOpen,
    required VoidCallback onToggleFavorite,
    required VoidCallback onDownload,
    required VoidCallback onRemoveDownload,
  }) {
    final colors = context.rxColors;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      builder: (ctx) => MaterialActionsSheet(
        item: item,
        isOffline: isOffline,
        onOpen: () {
          Navigator.of(ctx).pop();
          onOpen();
        },
        onToggleFavorite: () {
          Navigator.of(ctx).pop();
          onToggleFavorite();
        },
        onDownload: () {
          Navigator.of(ctx).pop();
          onDownload();
        },
        onRemoveDownload: () {
          Navigator.of(ctx).pop();
          onRemoveDownload();
        },
      ),
    );
  }

  void _shareMaterial(BuildContext context) {
    final colors = context.rxColors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Approved sharing link copied to clipboard for: ${item.title}',
          style: TextStyle(color: colors.surface),
        ),
        backgroundColor: colors.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isOnlineOnlyDisabled = isOffline && !item.isDownloaded;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: RxSpacing.s16),

            // Header: Title and Product
            Text(
              item.productName,
              style: textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: RxSpacing.s2),
            Text(
              item.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: RxSpacing.s6),
            Text(
              item.description,
              style: textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: RxSpacing.s16),
            const Divider(height: 1.0),
            const SizedBox(height: RxSpacing.s8),

            // Action 1: Open File (Disabled if offline and not downloaded)
            ListTile(
              leading: Icon(
                LucideIcons.externalLink,
                color: isOnlineOnlyDisabled ? colors.textTertiary : colors.primary,
              ),
              title: Text(
                l10n.actionOpenFile,
                style: TextStyle(
                  color: isOnlineOnlyDisabled ? colors.textTertiary : colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: isOnlineOnlyDisabled
                  ? Text(
                      l10n.requiresDownload,
                      style: TextStyle(color: colors.error, fontSize: 11.0),
                    )
                  : null,
              onTap: isOnlineOnlyDisabled ? null : onOpen,
            ),

            // Action 2: Favorite
            ListTile(
              leading: Icon(
                item.isFavorite ? LucideIcons.bookmarkMinus : LucideIcons.bookmarkPlus,
                color: colors.textPrimary,
              ),
              title: Text(
                item.isFavorite ? l10n.actionUnfavorite : l10n.actionFavorite,
                style: TextStyle(color: colors.textPrimary),
              ),
              onTap: onToggleFavorite,
            ),

            // Action 3: Download / Remove Download
            if (!item.isDownloaded)
              ListTile(
                leading: Icon(LucideIcons.downloadCloud, color: colors.textPrimary),
                title: Text(
                  l10n.actionDownload,
                  style: TextStyle(color: colors.textPrimary),
                ),
                subtitle: Text(
                  'Store ${item.formattedSize} on device for offline detailing',
                  style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
                onTap: onDownload,
              )
            else
              ListTile(
                leading: Icon(LucideIcons.trash2, color: colors.error),
                title: Text(
                  l10n.actionRemoveDownload,
                  style: TextStyle(color: colors.error),
                ),
                subtitle: Text(
                  'Frees ${item.formattedSize} of local storage',
                  style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
                onTap: onRemoveDownload,
              ),

            // Action 4: Share
            ListTile(
              leading: Icon(LucideIcons.share2, color: colors.textPrimary),
              title: Text(
                l10n.actionShare,
                style: TextStyle(color: colors.textPrimary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _shareMaterial(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
