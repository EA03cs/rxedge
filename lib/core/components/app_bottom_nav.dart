import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

class NavItemData {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? badge;

  const NavItemData({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// RxEdge Modern Executive Bottom Navigation Bar
///
/// Features:
/// - Modern pill capsule indicator around active icon
/// - Smooth active/inactive icon morphing
/// - Haptic selection feedback on tap
/// - Clean floating shadow with soft ambient blur
/// - Min 48dp touch targets meeting accessibility guidelines
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
    final mediaQuery = MediaQuery.of(context);
    final clampedScaler = mediaQuery.textScaler.clamp(maxScaleFactor: 1.15);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 16.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: Container(
            height: 66.0,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = currentIndex == index;
                final displayIcon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;
                final iconColor = isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B);
                final labelColor = isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B);

                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(index);
                      },
                      splashColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(16.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  width: isSelected ? 52.0 : 40.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark
                                            ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                                            : const Color(0xFFE0F2FE))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    displayIcon,
                                    size: 21.0,
                                    color: iconColor,
                                  ),
                                ),
                                if (item.badge != null)
                                  PositionedDirectional(
                                    top: -2,
                                    end: -4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: colors.accent,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        item.badge!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.0,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1.0),
                              child: SizedBox(
                                height: 26.0,
                                child: Center(
                                  child: Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: labelColor,
                                      letterSpacing: -0.15,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
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
      ),
    );
  }
}
