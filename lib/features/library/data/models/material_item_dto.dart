import '../../domain/entities/material_item_entity.dart';

/// DTO for Material Slide Data
class MaterialSlideDto {
  final int slideNumber;
  final String title;
  final String headline;
  final List<String> clinicalKeyPoints;
  final List<String> bulletEvidence;
  final String? chartCaption;
  final String? imageUrl;

  const MaterialSlideDto({
    required this.slideNumber,
    required this.title,
    required this.headline,
    required this.clinicalKeyPoints,
    required this.bulletEvidence,
    this.chartCaption,
    this.imageUrl,
  });

  factory MaterialSlideDto.fromJson(Map<String, dynamic> json) {
    return MaterialSlideDto(
      slideNumber:
          ((json['slide_number'] ?? json['slideOrder']) as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      clinicalKeyPoints: (json['clinical_key_points'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      bulletEvidence: (json['bullet_evidence'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      chartCaption: json['chart_caption'] as String?,
      imageUrl: json['image_url'] as String? ??
          json['imageUrl'] as String? ??
          json['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'slide_number': slideNumber,
        'title': title,
        'headline': headline,
        'clinical_key_points': clinicalKeyPoints,
        'bullet_evidence': bulletEvidence,
        'chart_caption': chartCaption,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  MaterialSlide toDomain() => MaterialSlide(
        slideNumber: slideNumber,
        title: title,
        headline: headline,
        clinicalKeyPoints: clinicalKeyPoints,
        bulletEvidence: bulletEvidence,
        chartCaption: chartCaption,
        imageUrl: imageUrl,
      );
}

/// DTO for Resource Library Material Items
class MaterialItemDto {
  final String id;
  final String title;
  final String productName;
  final String category;
  final String fileType;
  final int fileSizeBytes;
  final String updatedAt;
  final String badge;
  final bool isFavorite;
  final bool isDownloaded;
  final int viewCount;
  final String description;
  final int pageCount;
  final List<MaterialSlideDto> slides;
  final String? fileUrl;
  final String? thumbnailUrl;
  final int? slideOrder;

  const MaterialItemDto({
    required this.id,
    required this.title,
    required this.productName,
    required this.category,
    required this.fileType,
    required this.fileSizeBytes,
    required this.updatedAt,
    this.badge = 'none',
    this.isFavorite = false,
    this.isDownloaded = false,
    this.viewCount = 0,
    required this.description,
    this.pageCount = 1,
    this.slides = const [],
    this.fileUrl,
    this.thumbnailUrl,
    this.slideOrder,
  });

  factory MaterialItemDto.fromJson(Map<String, dynamic> json) {
    final backendType = (json['type'] as String?)?.toLowerCase();
    final mappedCategory = json['category'] as String? ??
        _categoryFromBackendType(backendType);
    final mappedFileType = json['file_type'] as String? ??
        _fileTypeFromBackendType(backendType);
    final updatedRaw = json['updated_at'] as String? ??
        json['updatedAt'] as String? ??
        json['createdAt'] as String? ??
        DateTime.now().toIso8601String();
    final version = (json['version'] as num?)?.toInt() ?? 1;
    final resolvedBadge = json['badge'] as String? ??
        _deriveBadge(version: version, createdAtRaw: json['createdAt'] as String?);
    final fileUrl = json['file_url'] as String? ?? json['fileUrl'] as String?;
    final thumbnailUrl =
        json['thumbnail_url'] as String? ?? json['thumbnailUrl'] as String?;
    final rawSlides = json['slides'] as List<dynamic>? ?? const [];

    return MaterialItemDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      productName: json['product_name'] as String? ??
          json['productName'] as String? ??
          '',
      category: mappedCategory,
      fileType: mappedFileType,
      fileSizeBytes: ((json['file_size_bytes'] ??
                  json['file_size'] ??
                  json['fileSize']) as num?)
              ?.toInt() ??
          1024 * 1024,
      updatedAt: updatedRaw,
      badge: resolvedBadge,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      pageCount: (json['page_count'] as num?)?.toInt() ??
          (rawSlides.isNotEmpty ? rawSlides.length : 1),
      slides: rawSlides
          .map((e) => MaterialSlideDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      fileUrl: fileUrl,
      thumbnailUrl: thumbnailUrl ??
          (mappedFileType == 'image' ? fileUrl : null),
      slideOrder: (json['slideOrder'] as num?)?.toInt(),
    );
  }

  static String _categoryFromBackendType(String? backendType) {
    switch (backendType) {
      case 'e_detailing':
        return 'edetail';
      case 'research_document':
        return 'marketing';
      case 'product_packshot':
      case 'diagram':
        return 'visual_aid';
      case 'clinical_pdf':
      default:
        return 'brochure';
    }
  }

  static String _fileTypeFromBackendType(String? backendType) {
    switch (backendType) {
      case 'e_detailing':
        return 'edetail';
      case 'product_packshot':
      case 'diagram':
        return 'image';
      case 'clinical_pdf':
      case 'research_document':
      default:
        return 'pdf';
    }
  }

  static String _deriveBadge({required int version, String? createdAtRaw}) {
    if (version > 1) return 'updated';
    final created = createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null;
    if (created != null &&
        DateTime.now().difference(created).inDays <= 14) {
      return 'new';
    }
    return 'none';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'product_name': productName,
        'category': category,
        'file_type': fileType,
        'file_size_bytes': fileSizeBytes,
        'updated_at': updatedAt,
        'badge': badge,
        'is_favorite': isFavorite,
        'is_downloaded': isDownloaded,
        'view_count': viewCount,
        'description': description,
        'page_count': pageCount,
        'slides': slides.map((e) => e.toJson()).toList(),
        if (fileUrl != null) 'file_url': fileUrl,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (slideOrder != null) 'slideOrder': slideOrder,
      };

  MaterialCategory _mapCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'brochure':
        return MaterialCategory.brochure;
      case 'visual_aid':
      case 'visualaid':
        return MaterialCategory.visualAid;
      case 'edetail':
      case 'e_detail':
        return MaterialCategory.edetail;
      case 'marketing':
        return MaterialCategory.marketing;
      default:
        return MaterialCategory.brochure;
    }
  }

  MaterialFileType _mapFileType(String ft) {
    switch (ft.toLowerCase()) {
      case 'image':
      case 'jpg':
      case 'png':
        return MaterialFileType.image;
      case 'edetail':
      case 'edetailslides':
      case 'slides':
        return MaterialFileType.edetailSlides;
      case 'pdf':
      default:
        return MaterialFileType.pdf;
    }
  }

  MaterialBadge _mapBadge(String b) {
    switch (b.toLowerCase()) {
      case 'new':
      case 'new_release':
        return MaterialBadge.newRelease;
      case 'updated':
        return MaterialBadge.updated;
      default:
        return MaterialBadge.none;
    }
  }

  MaterialItemEntity toDomain() {
    final mappedSlides = slides.map((e) => e.toDomain()).toList();
    return MaterialItemEntity(
      id: id,
      title: title,
      productName: productName,
      category: _mapCategory(category),
      fileType: _mapFileType(fileType),
      fileSizeBytes: fileSizeBytes,
      updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
      badge: _mapBadge(badge),
      isFavorite: isFavorite,
      downloadState: isDownloaded ? Downloaded(DateTime.now()) : const NotDownloaded(),
      viewCount: viewCount,
      description: description,
      pageCount: pageCount,
      slides: mappedSlides,
      fileUrl: fileUrl,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
