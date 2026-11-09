import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Loading skeleton for Challenges Tab
///
/// Follows UX Law:
/// "Every screen has designed loading (skeleton)."
/// Purely flat, gentle opacity pulse, matching challenge cards layout.
class ChallengesSkeletonLoader extends StatelessWidget {
  const ChallengesSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented control skeleton
          const SkeletonBox(
            width: double.infinity,
            height: 42.0,
            borderRadius: RxRadii.borderButton,
          ),
          const SizedBox(height: RxSpacing.s20),

          // Header card skeleton
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 80.0, height: 20.0, borderRadius: RxRadii.borderBadge),
                    SkeletonBox(width: 90.0, height: 20.0, borderRadius: RxRadii.borderBadge),
                  ],
                ),
                SizedBox(height: RxSpacing.s12),
                SkeletonBox(width: 220.0, height: 22.0),
                SizedBox(height: RxSpacing.s8),
                SkeletonBox(width: double.infinity, height: 14.0),
                SizedBox(height: RxSpacing.s6),
                SkeletonBox(width: 260.0, height: 14.0),
                SizedBox(height: RxSpacing.s16),
                SkeletonBox(width: double.infinity, height: 8.0, borderRadius: RxRadii.borderChip),
              ],
            ),
          ),
          const SizedBox(height: RxSpacing.s16),

          // Leaderboard item skeletons
          ...List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsetsDirectional.only(bottom: RxSpacing.s8),
              child: AppCard(
                padding: EdgeInsetsDirectional.all(RxSpacing.s12),
                child: Row(
                  children: [
                    SkeletonBox(width: 28.0, height: 28.0, isCircle: true),
                    SizedBox(width: RxSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 130.0, height: 14.0),
                          SizedBox(height: RxSpacing.s4),
                          SkeletonBox(width: 170.0, height: 11.0),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 60.0, height: 18.0, borderRadius: RxRadii.borderBadge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
