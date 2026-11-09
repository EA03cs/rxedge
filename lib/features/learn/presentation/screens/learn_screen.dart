import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Learning Modules',
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
              title: 'Clinical Certifications',
              subtitle: 'Micro-courses and detailing efficacy training',
            ),
            const SizedBox(height: RxSpacing.s8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusBadge(
                    label: 'Mandatory',
                    variant: StatusBadgeVariant.warning,
                    showDot: true,
                  ),
                  const SizedBox(height: RxSpacing.s12),
                  Text(
                    'Lipid Lowering Agents: Phase IV Trial Insights',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s4),
                  Text(
                    '5 modules • Estimated completion time: 12 minutes',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s16),
                  const ProgressBar(
                    value: 0.60,
                    height: 6.0,
                    label: 'Course Progress',
                    trailingText: '3/5 Completed',
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
