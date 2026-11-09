import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme.dart';

/// Global Search Bar trigger on the Home Tab
///
/// Features:
/// - 48dp touch target
/// - Flat surface with hairline 1px border
/// - 12dp radius (RxRadii.borderInput)
/// - Directional search icon and placeholder
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Semantics(
        button: true,
        label: l10n.searchHintHome,
        child: Material(
          color: colors.surface,
          borderRadius: RxRadii.borderInput,
          child: InkWell(
            borderRadius: RxRadii.borderInput,
            onTap: () => context.push(AppRoutes.search),
            child: Container(
              height: RxSpacing.s48,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
              decoration: BoxDecoration(
                borderRadius: RxRadii.borderInput,
                border: Border.all(
                  color: colors.border,
                  width: RxShadows.hairlineBorderWidth,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.search,
                    size: 18.0,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Text(
                      l10n.searchHintHome,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textTertiary,
                        fontSize: 14.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
