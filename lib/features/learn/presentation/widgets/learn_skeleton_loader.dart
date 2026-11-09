import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Loading skeleton for Smart Learning Hub
///
/// Follows UX Law:
/// "Every screen has designed loading (skeleton)."
/// Purely flat, gentle opacity pulse, matching product card layout.
class LearnSkeletonLoader extends StatelessWidget {
  const LearnSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 160.0, height: 22.0),
                  SizedBox(height: RxSpacing.s6),
                  SkeletonBox(width: 220.0, height: 14.0),
                ],
              ),
              SkeletonBox(width: 90.0, height: 36.0, borderRadius: RxRadii.borderButton),
            ],
          ),
          const SizedBox(height: RxSpacing.s20),

          // Product card skeletons
          ...List.generate(3, (index) => const _ProductCardSkeleton()),
        ],
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonBox(width: 72.0, height: 20.0, borderRadius: RxRadii.borderBadge),
                      SizedBox(width: RxSpacing.s8),
                      SkeletonBox(width: 64.0, height: 20.0, borderRadius: RxRadii.borderBadge),
                    ],
                  ),
                  SizedBox(height: RxSpacing.s10),
                  SkeletonBox(width: 140.0, height: 18.0),
                  SizedBox(height: RxSpacing.s6),
                  SkeletonBox(width: 180.0, height: 13.0),
                  SizedBox(height: RxSpacing.s10),
                  SkeletonBox(width: 110.0, height: 12.0),
                ],
              ),
            ),
            SizedBox(width: RxSpacing.s16),
            SkeletonBox.circle(size: 52.0),
          ],
        ),
      ),
    );
  }
}
