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
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Semantics(
        button: true,
        label: l10n.searchHintHome,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(30.0),
            onTap: () => context.push(AppRoutes.search),
            child: Container(
              height: 52.0,
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 8.0, 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00386E).withValues(alpha: 0.05),
                    blurRadius: 10.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.search,
                    size: 18.0,
                    color: Color(0xFF1E293B),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Text(
                      l10n.searchHintHome,
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E5E6D), // Teal button
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      LucideIcons.slidersHorizontal,
                      size: 16.0,
                      color: Colors.white,
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
