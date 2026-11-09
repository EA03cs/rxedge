import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Loading skeleton for Marketing Feedback Home
class FeedbackSkeletonLoader extends StatelessWidget {
  const FeedbackSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle skeleton
          const SkeletonBox(width: 240.0, height: 14.0),
          const SizedBox(height: RxSpacing.s16),

          // 3 Type Cards Skeletons
          ...List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
              child: AppCard(
                child: Row(
                  children: [
                    SkeletonBox(width: 40.0, height: 40.0, borderRadius: RxRadii.borderButton),
                    SizedBox(width: RxSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 130.0, height: 16.0),
                          SizedBox(height: RxSpacing.s4),
                          SkeletonBox(width: double.infinity, height: 12.0),
                        ],
                      ),
                    ),
                    SizedBox(width: RxSpacing.s8),
                    SkeletonBox(width: 16.0, height: 16.0, isCircle: true),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: RxSpacing.s20),

          // "My Submissions" header skeleton
          const SkeletonBox(width: 140.0, height: 18.0),
          const SizedBox(height: RxSpacing.s12),

          // Submissions items skeletons
          ...List.generate(
            2,
            (index) => const Padding(
              padding: EdgeInsetsDirectional.only(bottom: RxSpacing.s10),
              child: AppCard(
                padding: EdgeInsetsDirectional.all(RxSpacing.s12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 180.0, height: 14.0),
                          SizedBox(height: RxSpacing.s4),
                          SkeletonBox(width: 110.0, height: 11.0),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 70.0, height: 20.0, borderRadius: RxRadii.borderBadge),
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
