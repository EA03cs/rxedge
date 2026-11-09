import 'package:flutter/material.dart';
import '../theme/theme.dart';

class NavItemData {
  final IconData icon;
  final String label;
  final String? badge;

  const NavItemData({
    required this.icon,
    required this.label,
    this.badge,
  });
}

/// RxEdge Standard Bottom Navigation Bar
///
/// Follows Design System Rules:
/// - "One icon set only (Lucide). Every icon has a text label in navigation."
/// - "Touch targets min 48dp."
/// - Active state in primary deep teal.
/// - Flat surface with 1px top hairline border and subtle floating shadow.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: RxShadows.hairlineBorderWidth,
          ),
        ),
        boxShadow: isDark ? RxShadows.floatingDark : RxShadows.floatingLight,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              final color = isSelected ? colors.primary : colors.textTertiary;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    splashColor: colors.primarySoft.withValues(alpha: 0.5),
                    highlightColor: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: RxSpacing.minTouchTarget),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                item.icon,
                                size: 20.0,
                                color: color,
                              ),
                              if (item.badge != null)
                                PositionedDirectional(
                                  top: -3,
                                  end: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: colors.accent,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      item.badge!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: RxSpacing.s4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: color,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
