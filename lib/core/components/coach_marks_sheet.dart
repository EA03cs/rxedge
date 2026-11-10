import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/l10n/l10n.dart';
import '../../app/theme/theme.dart';
import '../services/coach_marks_service.dart';
import 'app_button.dart';

/// First-use Coach Marks sheet (Brief, skippable, once only)
class CoachMarksSheet extends ConsumerStatefulWidget {
  const CoachMarksSheet({super.key});

  static bool _hasShown = false;

  static Future<void> showIfFirstUse(BuildContext context, WidgetRef ref) async {
    if (_hasShown) return;
    final shouldShow = ref.read(coachMarksProvider);
    if (shouldShow && context.mounted) {
      _hasShown = true;
      await showModalBottomSheet<void>(
        context: context,
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
        builder: (_) => const CoachMarksSheet(),
      );
      if (context.mounted) {
        ref.read(coachMarksProvider.notifier).completeCoachMarks();
      }
    }
  }

  @override
  ConsumerState<CoachMarksSheet> createState() => _CoachMarksSheetState();
}

class _CoachMarksSheetState extends ConsumerState<CoachMarksSheet> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final steps = [
      _CoachStep(
        icon: LucideIcons.stethoscope,
        title: l10n.coachMarkSlide1Title,
        description: l10n.coachMarkSlide1Desc,
      ),
      _CoachStep(
        icon: LucideIcons.hardDrive,
        title: l10n.coachMarkSlide2Title,
        description: l10n.coachMarkSlide2Desc,
      ),
      _CoachStep(
        icon: LucideIcons.messageSquare,
        title: l10n.coachMarkSlide3Title,
        description: l10n.coachMarkSlide3Desc,
      ),
    ];

    final current = steps[_currentStep];
    final isLast = _currentStep == steps.length - 1;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Skip Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.coachMarkTitle,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(coachMarksProvider.notifier).completeCoachMarks();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      l10n.btnSkip,
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RxSpacing.s16),

              // Icon circle
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: Icon(current.icon, size: 26.0, color: colors.primary),
              ),
              const SizedBox(height: RxSpacing.s16),

              // Title
              Text(
                current.title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: RxSpacing.s8),

              // Description
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320.0),
                child: Text(
                  current.description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: RxSpacing.s24),

              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(steps.length, (index) {
                  final isActive = index == _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s4),
                    width: isActive ? 20.0 : 6.0,
                    height: 6.0,
                    decoration: BoxDecoration(
                      color: isActive ? colors.primary : colors.border,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  );
                }),
              ),
              const SizedBox(height: RxSpacing.s24),

              // Primary Next / Got It Button
              AppButton(
                text: isLast ? l10n.btnGotIt : l10n.next,
                onPressed: () {
                  if (isLast) {
                    ref.read(coachMarksProvider.notifier).completeCoachMarks();
                    Navigator.of(context).pop();
                  } else {
                    setState(() => _currentStep++);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachStep {
  final IconData icon;
  final String title;
  final String description;

  const _CoachStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
