import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/widgets/rx_network_image.dart';
import '../../domain/entities/material_item_entity.dart';
import '../controllers/library_controller.dart';

/// Full-Screen E-Detailing Slide Viewer for Physician Presentations
///
/// Features:
/// - Full-screen presentation mode
/// - Landscape and portrait responsive layout
/// - Swipe between slides (PageView)
/// - Hide-chrome on tap with smooth 200ms functional animation
/// - Distraction-free clinical slide counter pill
/// - Instant physician detailing key talking points sheet
class EdetailViewerScreen extends ConsumerStatefulWidget {
  final MaterialItemEntity material;

  const EdetailViewerScreen({
    super.key,
    required this.material,
  });

  @override
  ConsumerState<EdetailViewerScreen> createState() => _EdetailViewerScreenState();
}

class _EdetailViewerScreenState extends ConsumerState<EdetailViewerScreen> {
  late final PageController _pageController;
  int _currentSlideIndex = 0;
  bool _showChrome = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<MaterialSlide> get _slides {
    if (widget.material.slides.isNotEmpty) {
      return widget.material.slides;
    }
    // Fallback slide if none provided
    return [
      MaterialSlide(
        slideNumber: 1,
        title: widget.material.title,
        headline: 'Comprehensive clinical efficacy and patient compliance summary.',
        clinicalKeyPoints: [
          'High therapeutic efficacy profile demonstrated across clinical trials.',
          'Favorable safety with low discontinuation rates.',
        ],
        bulletEvidence: [
          'Landmark multinational double-blind randomized study results.',
          'Demonstrated 24-hour sustained therapeutic coverage.',
        ],
      ),
    ];
  }

  void _toggleChrome() {
    setState(() {
      _showChrome = !_showChrome;
    });
  }

  void _showDetailingNotes(BuildContext context, MaterialSlide slide) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: RxRadii.borderSheet),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: RxSpacing.s16),

                Row(
                  children: [
                    Icon(LucideIcons.lightbulb, size: 18.0, color: colors.primary),
                    const SizedBox(width: RxSpacing.s8),
                    Text(
                      l10n.detailingKeyPoints,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RxSpacing.s12),

                Text(
                  slide.title,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: RxSpacing.s8),

                ...slide.clinicalKeyPoints.map((point) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final slides = _slides;
    final totalSlides = slides.length;
    final currentSlide = slides[_currentSlideIndex];

    return Scaffold(
      backgroundColor: colors.surfaceMuted,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleChrome,
        child: Stack(
          children: [
            // 1. Full-Screen PageView of Slides
            PageView.builder(
              controller: _pageController,
              itemCount: totalSlides,
              onPageChanged: (index) {
                setState(() {
                  _currentSlideIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final slide = slides[index];
                return _buildSlideCanvas(context, slide, colors, textTheme);
              },
            ),

            // 2. Animated Top Chrome Header
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              top: _showChrome ? 0.0 : -100.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.95),
                  border: Border(
                    bottom: BorderSide(
                      color: colors.border,
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: RxSpacing.s8,
                      vertical: RxSpacing.s6,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(context.arrowBack, color: colors.textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: RxSpacing.s4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.material.productName,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                widget.material.title,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            widget.material.isFavorite ? LucideIcons.bookmark : LucideIcons.bookmark,
                            color: widget.material.isFavorite ? colors.primary : colors.textSecondary,
                          ),
                          onPressed: () {
                            ref
                                .read(libraryControllerProvider.notifier)
                                .toggleFavorite(widget.material.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Animated Bottom Chrome Bar & Slide Counter
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              bottom: _showChrome ? 0.0 : -100.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(
                      color: colors.border,
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: RxSpacing.s16,
                      vertical: RxSpacing.s8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Key talking points button
                        OutlinedButton.icon(
                          onPressed: () => _showDetailingNotes(context, currentSlide),
                          icon: Icon(LucideIcons.fileText, size: 16.0, color: colors.primary),
                          label: Text(
                            l10n.detailingKeyPoints,
                            style: textTheme.labelMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.border),
                            shape: const RoundedRectangleBorder(
                              borderRadius: RxRadii.borderButton,
                            ),
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: RxSpacing.s12,
                              vertical: RxSpacing.s8,
                            ),
                          ),
                        ),

                        // Right: Distraction-free Slide Counter Pill
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: RxSpacing.s12,
                            vertical: RxSpacing.s6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.textPrimary,
                            borderRadius: RxRadii.borderChip,
                          ),
                          child: Text(
                            l10n.slideIndicator(_currentSlideIndex + 1, totalSlides),
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.surface,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideCanvas(
    BuildContext context,
    MaterialSlide slide,
    RxColors colors,
    TextTheme textTheme,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: RxSpacing.s20,
          vertical: RxSpacing.s32,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
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
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Slide Topic Pill
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
                  slide.title.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(height: RxSpacing.s14),

              // Slide Headline
              Text(
                slide.headline,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: RxSpacing.s20),

              if ((slide.imageUrl ?? widget.material.fileUrl)?.trim().isNotEmpty ==
                  true) ...[
                RxNetworkImage(
                  imageUrl: slide.imageUrl ?? widget.material.fileUrl,
                  width: double.infinity,
                  height: 220.0,
                  fit: BoxFit.contain,
                  borderRadius: RxRadii.borderBadge,
                  fallbackIcon: LucideIcons.presentation,
                ),
                const SizedBox(height: RxSpacing.s20),
              ],

              // Clinical Evidence Bullets
              ...slide.bulletEvidence.map((evidence) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: RxSpacing.s12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsetsDirectional.only(top: 6.0),
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: RxSpacing.s10),
                      Expanded(
                        child: Text(
                          evidence,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              if (slide.chartCaption != null) ...[
                const SizedBox(height: RxSpacing.s16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.all(RxSpacing.s12),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: RxRadii.borderBadge,
                    border: Border.all(
                      color: colors.border,
                      width: RxShadows.hairlineBorderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.barChart2, size: 16.0, color: colors.primary),
                      const SizedBox(width: RxSpacing.s8),
                      Expanded(
                        child: Text(
                          slide.chartCaption!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
