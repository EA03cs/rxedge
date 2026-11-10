import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// "What's New" Section
///
/// Features:
/// - List of approved clinical materials recently updated or added
/// - NEW and UPDATED badges using restrained StatusBadge tokens
/// - Tap navigates to the scientific Library
class WhatsNewSection extends StatelessWidget {
  final List<MaterialUpdateEntity> materials;

  const WhatsNewSection({
    super.key,
    required this.materials,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.whatsNew,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: () => context.go(AppRoutes.library),
                borderRadius: RxRadii.borderBadge,
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(RxSpacing.s4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.tabLibrary,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s2),
                      Icon(
                        context.chevronForward,
                        size: 14.0,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RxSpacing.s10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: materials.length,
            separatorBuilder: (context, index) => const SizedBox(height: RxSpacing.s8),
            itemBuilder: (context, index) {
              final item = materials[index];
              final isNew = item.badgeType == MaterialBadgeType.newRelease;

              return AppCard(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RxSpacing.s12,
                  vertical: RxSpacing.s10,
                ),
                onTap: () => context.go(AppRoutes.library),
                child: Row(
                  children: [
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: RxRadii.borderBadge,
                        border: Border.all(
                          color: colors.border,
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.fileText,
                        size: 18.0,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: RxSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              height: 1.25,
                              fontSize: 13.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: RxSpacing.s2),
                          Text(
                            item.specialty,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: RxSpacing.s8),
                    StatusBadge(
                      label: isNew ? l10n.badgeNew : l10n.badgeUpdated,
                      variant: isNew ? StatusBadgeVariant.info : StatusBadgeVariant.neutral,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
