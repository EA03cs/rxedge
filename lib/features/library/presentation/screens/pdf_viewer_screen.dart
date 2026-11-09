import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../domain/entities/material_item_entity.dart';
import '../controllers/library_controller.dart';

/// PDF Monograph & Clinical Brochure Viewer
///
/// Features:
/// - Page indicator (Page X of Y)
/// - Zoom in, Zoom out, Fit to width, Pinch-to-zoom via InteractiveViewer
/// - Multi-page navigation (Next / Prev floating pill)
/// - Purely flat, professional medical reader layout
class PdfViewerScreen extends ConsumerStatefulWidget {
  final MaterialItemEntity material;

  const PdfViewerScreen({
    super.key,
    required this.material,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late final TransformationController _transformationController;
  int _currentPage = 1;
  late final int _totalPages;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _totalPages = widget.material.pageCount > 0 ? widget.material.pageCount : 6;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    _transformationController.value = matrix.multiplied(Matrix4.diagonal3Values(1.25, 1.25, 1.0));
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    _transformationController.value = matrix.multiplied(Matrix4.diagonal3Values(0.8, 0.8, 1.0));
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _resetZoom();
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _resetZoom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surfaceMuted,
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
              '${widget.material.productName} • ${l10n.pageIndicator(_currentPage, _totalPages)}',
              style: textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontSize: 11.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.zoomOut, size: 18.0, color: colors.textPrimary),
            tooltip: l10n.zoomOut,
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: Icon(LucideIcons.zoomIn, size: 18.0, color: colors.textPrimary),
            tooltip: l10n.zoomIn,
            onPressed: _zoomIn,
          ),
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
      body: Stack(
        children: [
          // 1. Zoomable Document Page Canvas
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 3.5,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 680),
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
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildDocumentContent(colors, textTheme, l10n),
                ),
              ),
            ),
          ),

          // 2. Floating Bottom Page Navigation Pill
          Positioned(
            bottom: RxSpacing.s20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RxSpacing.s8,
                  vertical: RxSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  borderRadius: RxRadii.borderChip,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.chevronLeft,
                        size: 18.0,
                        color: _currentPage > 1
                            ? colors.surface
                            : colors.surface.withValues(alpha: 0.35),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
                      onPressed: _currentPage > 1 ? _prevPage : null,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: RxSpacing.s8),
                      child: Text(
                        l10n.pageIndicator(_currentPage, _totalPages),
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.surface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        LucideIcons.chevronRight,
                        size: 18.0,
                        color: _currentPage < _totalPages
                            ? colors.surface
                            : colors.surface.withValues(alpha: 0.35),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
                      onPressed: _currentPage < _totalPages ? _nextPage : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentContent(
    RxColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Regulatory Top Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REGULATORY CLINICAL MONOGRAPH',
              style: textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontSize: 10.0,
              ),
            ),
            Text(
              'SECTION 0$_currentPage',
              style: textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: RxSpacing.s12),
        const Divider(height: 1.0),
        const SizedBox(height: RxSpacing.s16),

        Text(
          widget.material.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.3,
            height: 1.3,
          ),
        ),
        const SizedBox(height: RxSpacing.s8),

        Text(
          'Therapeutic Class: ${widget.material.productName} • Cardioprotective Indications',
          style: textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: RxSpacing.s20),

        // Monograph Body
        Text(
          '1. Indications & Clinical Pharmacology',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: RxSpacing.s8),
        Text(
          widget.material.description,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: RxSpacing.s16),

        // Simulated Dosage Table
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dosing Guidance & Pharmacokinetic Steady State',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: RxSpacing.s8),
              Text(
                '• Standard Initiation: 4mg once daily with morning or evening meal.\n'
                '• Titration Threshold: May increase to 8mg after 4 consecutive weeks of baseline evaluation.\n'
                '• Renal Clearance: No dosage adjustment required in CKD Stages 1 through 4.',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RxSpacing.s20),

        Text(
          '2. Efficacy in Key Randomized Controlled Trials',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: RxSpacing.s8),
        Text(
          'Across multinational double-blind trials, sustained 24-hour therapeutic coverage was demonstrated with a trough-to-peak ratio exceeding 78%. Holter ABPM monitoring confirmed reduction in night-time ambulatory systolic surges without reflexive orthostatic tachycardia.',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: RxSpacing.s24),

        // Footer signature
        const Divider(height: 1.0),
        const SizedBox(height: RxSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Document ID: ${widget.material.id.toUpperCase()}',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: RxSpacing.s8),
            Text(
              'Confidential Medical Detailing',
              style: textTheme.labelSmall?.copyWith(
                color: colors.textTertiary,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
