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
      title: json['title']?.toString() ?? '',
      headline: json['headline']?.toString() ?? '',
      clinicalKeyPoints: (json['clinical_key_points'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      bulletEvidence: (json['bullet_evidence'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      chartCaption: json['chart_caption']?.toString(),
      imageUrl: json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          json['fileUrl']?.toString(),
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
  final int? quarter;
  final int? year;

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
    this.quarter,
    this.year,
  });

  factory MaterialItemDto.fromJson(Map<String, dynamic> json) {
    final backendType = json['type']?.toString().toLowerCase();
    final mappedCategory = json['category']?.toString() ??
        _categoryFromBackendType(backendType);
    final mappedFileType = json['file_type']?.toString() ??
        _fileTypeFromBackendType(backendType);
    final updatedRaw = json['updated_at']?.toString() ??
        json['updatedAt']?.toString() ??
        json['createdAt']?.toString() ??
        DateTime.now().toIso8601String();
    final version = (json['version'] as num?)?.toInt() ?? 1;
    final resolvedBadge = json['badge']?.toString() ??
        _deriveBadge(version: version, createdAtRaw: json['createdAt']?.toString());
    final fileUrl = json['file_url']?.toString() ?? json['fileUrl']?.toString();
    final thumbnailUrl =
        json['thumbnail_url']?.toString() ?? json['thumbnailUrl']?.toString();
    final rawSlides = json['slides'] as List<dynamic>? ?? const [];

    String? resolvedProductName;
    if (json['productName'] != null && json['productName'] is! Map) {
      resolvedProductName = json['productName'].toString();
    } else if (json['product_name'] != null && json['product_name'] is! Map) {
      resolvedProductName = json['product_name'].toString();
    } else if (json['product'] is Map) {
      final pMap = json['product'] as Map;
      resolvedProductName = (pMap['name'] ?? pMap['brandCode'])?.toString();
    } else if (json['product'] != null) {
      resolvedProductName = json['product'].toString();
    }

    return MaterialItemDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      productName: resolvedProductName ?? '',
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
      description: json['description']?.toString() ?? '',
      pageCount: (json['page_count'] as num?)?.toInt() ??
          (rawSlides.isNotEmpty ? rawSlides.length : 1),
      slides: rawSlides
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => MaterialSlideDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      fileUrl: fileUrl,
      thumbnailUrl: thumbnailUrl ??
          (mappedFileType == 'image' ? fileUrl : null),
      slideOrder: (json['slideOrder'] as num?)?.toInt(),
      quarter: (json['quarter'] as num?)?.toInt(),
      year: (json['year'] as num?)?.toInt(),
    );
  }

  static String _categoryFromBackendType(String? backendType) {
    switch (backendType) {
      case 'e_detailing':
      case 'e_detailed_slides':
        return 'edetail';
      case 'brochure':
        return 'brochure';
      case 'visual_aid':
      case 'product_packshot':
      case 'diagram':
        return 'visual_aid';
      case 'research_document':
        return 'marketing';
      case 'clinical_pdf':
      default:
        return 'brochure';
    }
  }

  static String _fileTypeFromBackendType(String? backendType) {
    switch (backendType) {
      case 'e_detailing':
      case 'e_detailed_slides':
        return 'edetail';
      case 'product_packshot':
      case 'diagram':
      case 'image':
        return 'image';
      case 'brochure':
      case 'visual_aid':
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
      quarter: quarter,
      year: year,
    );
  }
}
