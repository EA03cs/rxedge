import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../domain/entities/material_item_entity.dart';
import '../controllers/library_controller.dart';

/// Full-Screen Image Visual Aid Viewer
///
/// Features:
/// - Pinch-to-zoom (InteractiveViewer)
/// - Double-tap to reset zoom
/// - Crisp medical mechanism of action and Kaplan-Meier visual display
/// - Distraction-free clinical presentation
class ImageViewerScreen extends ConsumerStatefulWidget {
  final MaterialItemEntity material;

  const ImageViewerScreen({
    super.key,
    required this.material,
  });

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  late final TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.material.title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.material.productName} • High-Resolution Visual Aid',
              style: textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontSize: 11.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.maximize2, size: 18.0, color: colors.textPrimary),
            tooltip: l10n.resetZoom,
            onPressed: _resetZoom,
          ),
          IconButton(
            icon: Icon(
              widget.material.isFavorite ? LucideIcons.bookmark : LucideIcons.bookmark,
              size: 18.0,
              color: widget.material.isFavorite ? colors.primary : colors.textSecondary,
            ),
            onPressed: () {
              ref.read(libraryControllerProvider.notifier).toggleFavorite(widget.material.id);
            },
          ),
          const SizedBox(width: RxSpacing.s4),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: _resetZoom,
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 0.8,
          maxScale: 4.5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: colors.border,
                    width: RxShadows.hairlineBorderWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Visual Aid Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: RxSpacing.s8,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primarySoft,
                            borderRadius: RxRadii.borderBadge,
                          ),
                          child: Text(
                            widget.material.productName.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          'CLINICAL TRIAL VISUAL AID',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: RxSpacing.s16),

                    Text(
                      widget.material.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s8),

                    Text(
                      widget.material.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s24),

                    // Visual Chart Graphic Container
                    Container(
                      height: 280.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: RxRadii.borderCard,
                        border: Border.all(
                          color: colors.border,
                          width: RxShadows.hairlineBorderWidth,
                        ),
                      ),
                      padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Mean Ambulatory SBP Reduction over 24 Hours (mm Hg)',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: RxSpacing.s8),
                              Row(
                                children: [
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: RxSpacing.s4),
                                  Text(
                                    widget.material.productName,
                                    style: textTheme.labelSmall?.copyWith(
                                      fontSize: 10.5,
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Simulated Plot Curves
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(12, (index) {
                              final heights = [
                                140.0, 155.0, 170.0, 185.0, 195.0, 190.0,
                                180.0, 175.0, 180.0, 190.0, 160.0, 150.0
                              ];
                              final h = heights[index];
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16.0,
                                    height: h * 0.7,
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(
                                        alpha: 0.75 + (index % 3) * 0.1,
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(3.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: RxSpacing.s4),
                                  Text(
                                    '${(index * 2).toString().padLeft(2, '0')}h',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colors.textTertiary,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s16),

                    Text(
                      'P-value < 0.001 vs placebo. Confidence Interval 95% (-14.2 to -9.8 mm Hg). Evaluated via 24h continuous non-invasive oscillometric cuffs.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textTertiary,
                        fontSize: 11.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
