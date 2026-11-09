import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Field Challenges',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Weekly Detailing Streaks',
              subtitle: 'Consistency recognition and territory milestone badges',
            ),
            const SizedBox(height: RxSpacing.s8),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: colors.accentSoft,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: 0.3),
                        width: RxShadows.hairlineBorderWidth,
                      ),
                    ),
                    child: Icon(LucideIcons.award, size: 24.0, color: colors.accent),
                  ),
                  const SizedBox(width: RxSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '7-Day Detailing Streak',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: RxSpacing.s8),
                            const StatusBadge(
                              label: '350 Pts',
                              variant: StatusBadgeVariant.accent,
                            ),
                          ],
                        ),
                        const SizedBox(height: RxSpacing.s2),
                        Text(
                          'Completed daily detailing quiz 7 consecutive days',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
