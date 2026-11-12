import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/network/url_resolver.dart';
import '../../../../core/storage/local_file_helper.dart';
import '../../domain/entities/material_item_entity.dart';
import '../controllers/library_controller.dart';

/// PDF Monograph & Clinical Brochure Viewer
///
/// Renders actual PDF documents via `pdfrx` from either:
/// 1) Downloaded offline local file (`widget.material.localFilePath`), or
/// 2) Remote resolved backend URL (`widget.material.fileUrl`).
///
/// Falls back cleanly to structured monograph metadata if no PDF binary exists yet.
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
  final PdfViewerController _pdfController = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 1;
  int _reloadToken = 0;

  bool get _hasLocalFile => localFileExists(widget.material.localFilePath);

  String? get _resolvedRemoteUrl => UrlResolver.resolve(widget.material.fileUrl);

  bool get _usesNativePdf {
    if (_hasLocalFile) return true;
    final remote = _resolvedRemoteUrl;
    return remote != null && Uri.tryParse(remote)?.hasScheme == true;
  }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _totalPages = widget.material.pageCount > 0 ? widget.material.pageCount : 1;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    if (_usesNativePdf && _pdfController.isReady) {
      _pdfController.zoomUp();
      return;
    }
    final matrix = _transformationController.value.clone();
    _transformationController.value =
        matrix.multiplied(Matrix4.diagonal3Values(1.25, 1.25, 1.0));
  }

  void _zoomOut() {
    if (_usesNativePdf && _pdfController.isReady) {
      _pdfController.zoomDown();
      return;
    }
    final matrix = _transformationController.value.clone();
    _transformationController.value =
        matrix.multiplied(Matrix4.diagonal3Values(0.8, 0.8, 1.0));
  }

  void _resetZoom() {
    if (_usesNativePdf && _pdfController.isReady) {
      final fitMatrix = _pdfController.calcMatrixForFit(pageNumber: _currentPage);
      if (fitMatrix != null) {
        _pdfController.goTo(fitMatrix);
      }
      return;
    }
    _transformationController.value = Matrix4.identity();
  }

  void _nextPage() {
    if (_currentPage >= _totalPages) return;
    final targetPage = _currentPage + 1;
    if (_usesNativePdf && _pdfController.isReady) {
      _pdfController.goToPage(pageNumber: targetPage);
    } else {
      setState(() {
        _currentPage = targetPage;
        _resetZoom();
      });
    }
  }

  void _prevPage() {
    if (_currentPage <= 1) return;
    final targetPage = _currentPage - 1;
    if (_usesNativePdf && _pdfController.isReady) {
      _pdfController.goToPage(pageNumber: targetPage);
    } else {
      setState(() {
        _currentPage = targetPage;
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
              LucideIcons.bookmark,
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
          // 1. Real PDF Reader or Metadata Summary Canvas
          if (_usesNativePdf)
            _buildNativePdfViewer(colors, textTheme, l10n)
          else
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
                    child: _buildFallbackMetadataContent(colors, textTheme, l10n),
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
                        context.chevronBack,
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
                        context.chevronForward,
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

  Widget _buildNativePdfViewer(
    RxColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    final params = PdfViewerParams(
      backgroundColor: colors.surfaceMuted,
      onViewerReady: (document, _) {
        if (!mounted) return;
        setState(() {
          _totalPages = document.pages.isNotEmpty ? document.pages.length : 1;
        });
      },
      onPageChanged: (pageNumber) {
        if (pageNumber == null || !mounted) return;
        setState(() => _currentPage = pageNumber);
      },
      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
        final progress = (totalBytes != null && totalBytes > 0)
            ? bytesDownloaded / totalBytes
            : null;
        return Center(
          child: Container(
            padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: RxRadii.borderCard,
              border: Border.all(
                color: colors.border,
                width: RxShadows.hairlineBorderWidth,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(value: progress, color: colors.primary),
                const SizedBox(height: RxSpacing.s12),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'جاري تحميل ملف الـ PDF...'
                      : 'Loading PDF document...',
                  style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
      errorBannerBuilder: (context, error, stackTrace, documentRef) {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsetsDirectional.all(RxSpacing.s16),
                decoration: BoxDecoration(
                  color: colors.warningSoft,
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: colors.warning.withValues(alpha: 0.3),
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(LucideIcons.fileWarning, size: 28.0, color: colors.warning),
                    const SizedBox(height: RxSpacing.s8),
                    Text(
                      isArabic
                          ? 'تعذر تحميل ملف الـ PDF حالياً'
                          : 'Unable to load the PDF file right now.',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: RxSpacing.s8),
                    TextButton.icon(
                      onPressed: () => setState(() => _reloadToken++),
                      icon: Icon(LucideIcons.refreshCw, size: 16.0, color: colors.primary),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: RxSpacing.s16),
              Container(
                constraints: const BoxConstraints(maxWidth: 680),
                padding: const EdgeInsetsDirectional.all(RxSpacing.s24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: RxRadii.borderCard,
                  border: Border.all(
                    color: colors.border,
                    width: RxShadows.hairlineBorderWidth,
                  ),
                ),
                child: _buildFallbackMetadataContent(colors, textTheme, l10n),
              ),
            ],
          ),
        );
      },
    );

    if (_hasLocalFile) {
      return PdfViewer.file(
        widget.material.localFilePath!,
        key: ValueKey('pdf_local_${widget.material.id}_$_reloadToken'),
        controller: _pdfController,
        params: params,
      );
    }

    return PdfViewer.uri(
      Uri.parse(_resolvedRemoteUrl!),
      key: ValueKey('pdf_net_${widget.material.id}_$_reloadToken'),
      controller: _pdfController,
      params: params,
    );
  }

  Widget _buildFallbackMetadataContent(
    RxColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Regulatory Top Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.regulatoryMonographHeader,
              style: textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontSize: 10.0,
              ),
            ),
            Text(
              l10n.sectionNumberLabel(_currentPage),
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
          l10n.therapeuticClassLabel(widget.material.productName),
          style: textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (widget.material.isDownloaded ||
            (widget.material.fileUrl?.trim().isNotEmpty == true)) ...[
          const SizedBox(height: RxSpacing.s8),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: RxSpacing.s8,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: widget.material.isDownloaded
                  ? colors.successSoft
                  : colors.primarySoft,
              borderRadius: RxRadii.borderBadge,
            ),
            child: Text(
              widget.material.isDownloaded
                  ? l10n.offlineAvailable
                  : '${l10n.onlineOnlyStatusBadge} • ${widget.material.formattedSize}',
              style: textTheme.labelSmall?.copyWith(
                color: widget.material.isDownloaded
                    ? colors.success
                    : colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11.0,
              ),
            ),
          ),
        ],
        const SizedBox(height: RxSpacing.s20),

        Text(
          widget.material.description,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            height: 1.5,
          ),
        ),
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
              Icon(LucideIcons.fileText, size: 18.0, color: colors.textSecondary),
              const SizedBox(width: RxSpacing.s10),
              Expanded(
                child: Text(
                  isArabic
                      ? 'لا يتوفر ملف PDF مرفق لهذه المادة حالياً، يمكنك الاطلاع على الملخص أعلاه.'
                      : 'No PDF document file is attached to this material yet; summary details are displayed above.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RxSpacing.s24),

        const Divider(height: 1.0),
        const SizedBox(height: RxSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.documentIdLabel(widget.material.id.toUpperCase()),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: RxSpacing.s8),
            Text(
              l10n.confidentialDetailingFooter,
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
