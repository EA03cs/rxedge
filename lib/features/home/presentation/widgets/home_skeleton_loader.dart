import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Skeleton Loading Layout for Home Tab
///
/// Follows UX Law:
/// "Skeleton loading for each section independently.
/// Purely flat, gentle opacity pulse, no shiny gradient shimmer."
class HomeSkeletonLoader extends StatelessWidget {
  const HomeSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Skeleton
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: RxSpacing.s16,
              vertical: RxSpacing.s12,
            ),
            child: Row(
              children: [
                SkeletonBox.circle(size: 40.0),
                SizedBox(width: RxSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox.text(width: 140.0, height: 16.0),
                      SizedBox(height: RxSpacing.s4),
                      SkeletonBox.text(width: 190.0, height: 12.0),
                    ],
                  ),
                ),
                SkeletonBox.circle(size: 32.0),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s4),

          // 2. Search Bar Skeleton
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
            child: SkeletonBox(
              height: RxSpacing.s48,
              borderRadius: RxRadii.borderInput,
            ),
          ),
          const SizedBox(height: RxSpacing.s16),

          // 3. Continue Learning Skeleton Card
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
            child: SkeletonBox.card(height: 160.0),
          ),
          const SizedBox(height: RxSpacing.s16),

          // 4. Monthly Challenge Skeleton Card
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
            child: SkeletonBox.card(height: 118.0),
          ),
          const SizedBox(height: RxSpacing.s16),

          // 5. Objection Skeleton Card
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
            child: SkeletonBox.card(height: 130.0),
          ),
          const SizedBox(height: RxSpacing.s16),

          // 6. Quick Actions Row Skeleton
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox.text(width: 100.0, height: 14.0),
                const SizedBox(height: RxSpacing.s10),
                Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: index < 2 ? RxSpacing.s8 : 0.0,
                        ),
                        child: const SkeletonBox(
                          height: 64.0,
                          borderRadius: RxRadii.borderCard,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s16),

          // 7. What's New Skeleton List
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox.text(width: 90.0, height: 14.0),
                const SizedBox(height: RxSpacing.s10),
                ...List.generate(3, (index) {
                  return const Padding(
                    padding: EdgeInsetsDirectional.only(bottom: RxSpacing.s8),
                    child: SkeletonBox(
                      height: 54.0,
                      borderRadius: RxRadii.borderCard,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s8),

          // 8. Stats Strip Skeleton
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
            child: SkeletonBox(
              height: 48.0,
              borderRadius: RxRadii.borderCard,
            ),
          ),
        ],
      ),
    );
  }
}
