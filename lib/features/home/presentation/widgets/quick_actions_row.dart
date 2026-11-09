import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';

/// Quick Actions Row (3 items)
///
/// Features:
/// - Quick quiz -> Learn Tab
/// - Send feedback -> Feedback Tab
/// - Search library -> Library Tab
/// - Min 48dp touch targets
/// - Strictly flat, hairline border, surface background
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final actions = [
      _QuickActionItem(
        icon: LucideIcons.helpCircle,
        label: l10n.quickActionQuiz,
        onTap: () => context.go(AppRoutes.learn),
      ),
      _QuickActionItem(
        icon: LucideIcons.messageSquare,
        label: l10n.quickActionFeedback,
        onTap: () => context.go(AppRoutes.feedback),
      ),
      _QuickActionItem(
        icon: LucideIcons.bookOpen,
        label: l10n.quickActionLibrary,
        onTap: () => context.go(AppRoutes.library),
      ),
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.quickActions,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: RxSpacing.s10),
          Row(
            children: actions.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index < actions.length - 1 ? RxSpacing.s8 : 0.0,
                  ),
                  child: Semantics(
                    button: true,
                    label: item.label,
                    child: Material(
                      color: colors.surface,
                      borderRadius: RxRadii.borderCard,
                      child: InkWell(
                        onTap: item.onTap,
                        borderRadius: RxRadii.borderCard,
                        splashColor: colors.primarySoft.withValues(alpha: 0.35),
                        highlightColor: colors.primarySoft.withValues(alpha: 0.15),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: RxSpacing.s48),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: RxSpacing.s8,
                            vertical: RxSpacing.s12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: RxRadii.borderCard,
                            border: Border.all(
                              color: colors.border,
                              width: RxShadows.hairlineBorderWidth,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                size: 20.0,
                                color: colors.primary,
                              ),
                              const SizedBox(height: RxSpacing.s6),
                              Text(
                                item.label,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
