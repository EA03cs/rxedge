import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Field Intelligence',
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
              title: 'Doctor Objections & Feedback',
              subtitle: 'Share direct field observations with medical & commercial marketing',
            ),
            const SizedBox(height: RxSpacing.s8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.messageSquare, size: 20.0, color: colors.primary),
                      const SizedBox(width: RxSpacing.s10),
                      Text(
                        'Submit Field Report',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s8),
                  Text(
                    'Reports are queued locally if offline and synced immediately once connected.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s16),
                  AppButton(
                    text: 'Record New Field Objection',
                    leadingIcon: LucideIcons.plus,
                    variant: AppButtonVariant.secondary,
                    onPressed: () {},
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
