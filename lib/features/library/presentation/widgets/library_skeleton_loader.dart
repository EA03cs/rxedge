import 'package:flutter/material.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Skeleton loader for Resource Library supporting grid and list layouts
class LibrarySkeletonLoader extends StatelessWidget {
  final bool isGridView;

  const LibrarySkeletonLoader({
    super.key,
    this.isGridView = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: RxSpacing.s12,
            mainAxisSpacing: RxSpacing.s12,
            childAspectRatio: 0.72,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return const SkeletonBox.card(height: 220.0);
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: RxSpacing.s10),
        itemBuilder: (context, index) {
          return const SkeletonBox(
            height: 80.0,
            borderRadius: RxRadii.borderCard,
          );
        },
      ),
    );
  }
}
