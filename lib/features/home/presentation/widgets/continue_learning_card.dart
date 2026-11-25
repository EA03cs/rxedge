import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/components/app_button.dart';
import '../../../learn/domain/entities/learning_entities.dart';
import '../../../learn/presentation/controllers/learn_controller.dart';
import '../../../learn/presentation/screens/learn_screen.dart';
import '../../../learn/presentation/screens/lesson_screen.dart';
import '../../../learn/presentation/screens/product_learning_screen.dart';
import '../../domain/entities/home_dashboard_entity.dart';

/// "Continue Learning" Card
///
/// Features:
/// 1. Active state: Product name, lesson title, progress bar with module counts, and single primary "Continue" button.
/// 2. Empty state (New MR): "Start with [recommended product]", clinical rationale, and single primary "Start Lesson" button.
///
/// STRICT DESIGN RULE:
/// This card contains the ONLY filled primary button visible on the Home Screen.
class ContinueLearningCard extends ConsumerWidget {
  final ContinueLearningEntity? lesson;
  final RecommendedProductEntity? recommendedProduct;

  const ContinueLearningCard({
    super.key,
    this.lesson,
    this.recommendedProduct,
  });

  void _openLearning(BuildContext context, WidgetRef ref) {
    final products = ref.read(learnControllerProvider).valueOrNull ?? [];
    if (products.isEmpty) {
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute(builder: (_) => const LearnScreen()),
      );
      return;
    }

    if (lesson != null) {
      ProductLearningEntity? matchedProduct;
      LessonEntity? matchedLesson;

      for (final p in products) {
        if (p.name == lesson!.productName || p.id == lesson!.id) {
          matchedProduct = p;
          for (final l in p.lessons) {
            if (l.title == lesson!.lessonTitle || l.id == lesson!.id) {
              matchedLesson = l;
              break;
            }
          }
          break;
        }
      }

      if (matchedLesson != null) {
        Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute(builder: (_) => LessonScreen(lesson: matchedLesson!)),
        );
        return;
      }

      if (matchedProduct != null) {
        Navigator.of(context, rootNavigator: true).push<void>(
          MaterialPageRoute(builder: (_) => ProductLearningScreen(product: matchedProduct!)),
        );
        return;
      }
    }

    final prod = products.firstWhere(
      (p) => p.name == recommendedProduct?.productName || p.id == recommendedProduct?.id,
      orElse: () => products.first,
    );

    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => ProductLearningScreen(product: prod)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22.0),
        child: InkWell(
          onTap: () => _openLearning(context, ref),
          borderRadius: BorderRadius.circular(22.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF003884), // Rich Sapphire Blue
                  Color(0xFF014E9E), // Vivid Royal Blue
                  Color(0xFF023674), // Deep Executive Navy
                  Color(0xFF001F4D), // Midnight Abyss
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(22.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002456).withValues(alpha: 0.38),
                  blurRadius: 20.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.0),
              child: CustomPaint(
                painter: const _LearningCardBackgroundPainter(isRtl: false),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 16.0, 18.0),
                  child: lesson != null
                      ? _buildActiveLearningState(context, ref, colors, textTheme, l10n, lesson!)
                      : _buildNewUserEmptyState(context, ref, colors, textTheme, l10n, recommendedProduct),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveLearningState(
    BuildContext context,
    WidgetRef ref,
    RxColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
    ContinueLearningEntity item,
  ) {
    final percentage = (item.progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section tag & Product Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.0,
                    height: 6.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2DD4BF), // Mint cyan
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: RxSpacing.s6),
                  Flexible(
                    child: Text(
                      l10n.continueLearningTitle.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF2DD4BF),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RxSpacing.s8),
            Flexible(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RxSpacing.s10,
                  vertical: RxSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  item.productName,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RxSpacing.s10),

        // Body Row: Text + Progress + Continue on Left, 3D Heart on Right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson Title
                  Text(
                    item.lessonTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      fontSize: 15.0,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: RxSpacing.s8),

                  // Micro-meta: play circle icon & module info
                  Row(
                    children: [
                      Container(
                        width: 18.0,
                        height: 18.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D9488),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          LucideIcons.play,
                          size: 9.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s6),
                      Flexible(
                        child: Text(
                          '${l10n.moduleProgressCount(item.completedModules, item.totalModules)} • ${l10n.minutesCountLabel(4)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF93C5FD),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s14),

                  // Mint Progress Bar + Percentage
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            minHeight: 5.5,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                          ),
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s10),
                      Text(
                        '$percentage%',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RxSpacing.s16),

                  // White Pill "Continue" Button
                  AppButton(
                    text: l10n.btnContinue,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.small,
                    isFullWidth: false,
                    leadingIcon: LucideIcons.play,
                    customBackgroundColor: Colors.white,
                    customForegroundColor: const Color(0xFF0F172A),
                    customBorderRadius: BorderRadius.circular(24.0),
                    onPressed: () => _openLearning(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RxSpacing.s8),

            // 3D Heart Illustration
            Center(
              child: Image.asset(
                'assets/images/home_heart_3d.png',
                width: 104.0,
                height: 122.0,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewUserEmptyState(
    BuildContext context,
    WidgetRef ref,
    RxColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
    RecommendedProductEntity? product,
  ) {
    final prodName = product?.productName ?? 'Rohto Dry Aid';
    final rationale =
        product?.description ?? l10n.recommendedDetailingSubtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.0,
                    height: 6.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2DD4BF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: RxSpacing.s6),
                  Flexible(
                    child: Text(
                      l10n.recommendedLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF2DD4BF),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RxSpacing.s8),
            Flexible(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RxSpacing.s10,
                  vertical: RxSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  prodName,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RxSpacing.s10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.noLessonStarted(prodName),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                      fontSize: 16.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: RxSpacing.s6),
                  Text(
                    rationale,
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFCCE4FF).withValues(alpha: 0.85),
                      height: 1.4,
                      fontSize: 12.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: RxSpacing.s16),
                  AppButton(
                    text: l10n.btnStartLesson,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.small,
                    isFullWidth: false,
                    leadingIcon: LucideIcons.play,
                    customBackgroundColor: Colors.white,
                    customForegroundColor: const Color(0xFF0F172A),
                    customBorderRadius: BorderRadius.circular(24.0),
                    onPressed: () => _openLearning(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RxSpacing.s8),
            Image.asset(
              'assets/images/home_heart_3d.png',
              width: 90.0,
              height: 110.0,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ],
    );
  }
}

class _LearningCardBackgroundPainter extends CustomPainter {
  final bool isRtl;

  const _LearningCardBackgroundPainter({this.isRtl = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft radial cyan/azure glow behind the 3D heart
    final heartCenterX = !isRtl ? w * 0.83 : w * 0.17;
    final heartCenterY = h * 0.52;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.75,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.35), // Vibrant cyan highlight
          const Color(0xFF0284C7).withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(heartCenterX, heartCenterY),
        radius: w * 0.35,
      ));
    canvas.drawCircle(Offset(heartCenterX, heartCenterY), w * 0.35, glowPaint);

    // 2. Decorative organic wave curves sweeping across the card
    final wavePaint1 = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final wavePath1 = Path();
    if (!isRtl) {
      wavePath1.moveTo(w * 0.48, h);
      wavePath1.cubicTo(
        w * 0.60, h * 0.70,
        w * 0.70, h * 0.38,
        w, h * 0.22,
      );
      wavePath1.lineTo(w, h);
      wavePath1.close();
    } else {
      wavePath1.moveTo(w * 0.52, h);
      wavePath1.cubicTo(
        w * 0.40, h * 0.70,
        w * 0.30, h * 0.38,
        0, h * 0.22,
      );
      wavePath1.lineTo(0, h);
      wavePath1.close();
    }
    canvas.drawPath(wavePath1, wavePaint1);

    final wavePaint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final wavePath2 = Path();
    if (!isRtl) {
      wavePath2.moveTo(w * 0.35, h);
      wavePath2.cubicTo(
        w * 0.50, h * 0.62,
        w * 0.65, h * 0.25,
        w, h * 0.08,
      );
      wavePath2.lineTo(w, h);
      wavePath2.close();
    } else {
      wavePath2.moveTo(w * 0.65, h);
      wavePath2.cubicTo(
        w * 0.50, h * 0.62,
        w * 0.35, h * 0.25,
        0, h * 0.08,
      );
      wavePath2.lineTo(0, h);
      wavePath2.close();
    }
    canvas.drawPath(wavePath2, wavePaint2);
  }

  @override
  bool shouldRepaint(covariant _LearningCardBackgroundPainter oldDelegate) =>
      oldDelegate.isRtl != isRtl;
}
