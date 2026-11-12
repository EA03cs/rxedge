import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../app/l10n/l10n.dart';
import '../../../../app/theme/theme.dart';
import '../../../../core/storage/local_file_helper.dart';
import '../../../../core/widgets/rx_network_image.dart';
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
              '${widget.material.productName} • ${l10n.clinicalVisualAidBadge}',
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

                    // Visual Chart Graphic Container (offline file or remote image)
                    if (widget.material.fileUrl?.trim().isNotEmpty == true ||
                        localFileExists(widget.material.localFilePath))
                      ClipRRect(
                        borderRadius: RxRadii.borderCard,
                        child: RxNetworkImage(
                          imageUrl: widget.material.fileUrl,
                          localFilePath: widget.material.localFilePath,
                          width: double.infinity,
                          height: 300.0,
                          fit: BoxFit.contain,
                          borderRadius: RxRadii.borderCard,
                          fallbackIcon: LucideIcons.image,
                        ),
                      )
                    else
                      Container(
                        height: 220.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: RxRadii.borderCard,
                          border: Border.all(
                            color: colors.border,
                            width: RxShadows.hairlineBorderWidth,
                          ),
                        ),
                        padding: const EdgeInsetsDirectional.all(RxSpacing.s20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.imageOff,
                              size: 36.0,
                              color: colors.textTertiary,
                            ),
                            const SizedBox(height: RxSpacing.s12),
                            Text(
                              Localizations.localeOf(context).languageCode == 'ar'
                                  ? 'لا توجد صورة مرفقة لهذه المادة العلمية حالياً'
                                  : 'No visual media file is attached to this material yet.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: RxSpacing.s16),

                    if (widget.material.fileUrl?.trim().isNotEmpty == true ||
                        localFileExists(widget.material.localFilePath))
                      Text(
                        widget.material.isDownloaded
                            ? l10n.offlineAvailable
                            : '${l10n.onlineOnlyStatusBadge} • ${widget.material.formattedSize}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textTertiary,
                          fontSize: 11.0,
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
