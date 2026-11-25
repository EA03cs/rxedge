import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/theme.dart';
import '../../../challenges/presentation/screens/challenges_screen.dart';
import '../../../feedback/presentation/screens/feedback_screen.dart';
import '../../../library/presentation/screens/library_screen.dart';

/// Quick Field Tools Bar on the Home Screen matching executive clinical design:
/// - One unified white card with 18dp radius and soft shadow
/// - 4 pastel rounded-square action buttons:
///   1. Visual Aid (Sky blue badge + Book/Document icon)
///   2. Quick Quiz (Mint teal badge + Zap icon)
///   3. Challenge (Lavender purple badge + Target icon)
///   4. Log Voice (Cyan badge + Voice/Note icon)
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final actions = [
      _ActionData(
        icon: LucideIcons.bookOpen,
        label: isArabic ? 'بروشور العرض' : 'Visual Aid',
        badgeBg: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0284C7),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(builder: (_) => const LibraryScreen()),
          );
        },
      ),
      _ActionData(
        icon: LucideIcons.zap,
        label: isArabic ? 'كويز سريع' : 'Quick Quiz',
        badgeBg: const Color(0xFFCCFBF1),
        iconColor: const Color(0xFF0D9488),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(
              builder: (_) => const ChallengesScreen(initialTabIndex: 1),
            ),
          );
        },
      ),
      _ActionData(
        icon: LucideIcons.target,
        label: isArabic ? 'التحدي الشهري' : 'Challenge',
        badgeBg: const Color(0xFFEDE9FE),
        iconColor: const Color(0xFF7C3AED),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(
              builder: (_) => const ChallengesScreen(initialTabIndex: 0),
            ),
          );
        },
      ),
      _ActionData(
        icon: LucideIcons.fileEdit,
        label: isArabic ? 'تسجيل اعتراض' : 'Log Voice',
        badgeBg: const Color(0xFFCFFAFE),
        iconColor: const Color(0xFF0891B2),
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(builder: (_) => const FeedbackScreen()),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        child: Row(
          children: actions.map((act) {
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: act.onTap,
                  borderRadius: BorderRadius.circular(14.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44.0,
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: act.badgeBg,
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            act.icon,
                            size: 20.0,
                            color: act.iconColor,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            act.label,
                            style: textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final Color badgeBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.badgeBg,
    required this.iconColor,
    required this.onTap,
  });
}
