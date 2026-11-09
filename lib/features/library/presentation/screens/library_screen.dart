import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Scientific Library',
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
              title: 'Approved Medical Monographs',
              subtitle: 'Formulary dossiers and FDA approved prescribing information',
            ),
            const SizedBox(height: RxSpacing.s8),
            AppCard(
              variant: AppCardVariant.muted,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(RxSpacing.s10),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: colors.border, width: RxShadows.hairlineBorderWidth),
                    ),
                    child: Icon(LucideIcons.fileText, size: 20.0, color: colors.primary),
                  ),
                  const SizedBox(width: RxSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cardiovascular Monograph Directory',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: RxSpacing.s2),
                        Text(
                          '18 approved product study summaries cached for offline access',
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
