import '../../domain/entities/material_item_entity.dart';

/// DTO for Material Slide Data
class MaterialSlideDto {
  final int slideNumber;
  final String title;
  final String headline;
  final List<String> clinicalKeyPoints;
  final List<String> bulletEvidence;
  final String? chartCaption;

  const MaterialSlideDto({
    required this.slideNumber,
    required this.title,
    required this.headline,
    required this.clinicalKeyPoints,
    required this.bulletEvidence,
    this.chartCaption,
  });

  factory MaterialSlideDto.fromJson(Map<String, dynamic> json) {
    return MaterialSlideDto(
      slideNumber: json['slide_number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      clinicalKeyPoints: (json['clinical_key_points'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      bulletEvidence: (json['bullet_evidence'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      chartCaption: json['chart_caption'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'slide_number': slideNumber,
        'title': title,
        'headline': headline,
        'clinical_key_points': clinicalKeyPoints,
        'bullet_evidence': bulletEvidence,
        'chart_caption': chartCaption,
      };

  MaterialSlide toDomain() => MaterialSlide(
        slideNumber: slideNumber,
        title: title,
        headline: headline,
        clinicalKeyPoints: clinicalKeyPoints,
        bulletEvidence: bulletEvidence,
        chartCaption: chartCaption,
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
  });

  factory MaterialItemDto.fromJson(Map<String, dynamic> json) {
    return MaterialItemDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      category: json['category'] as String? ?? 'brochure',
      fileType: json['file_type'] as String? ?? 'pdf',
      fileSizeBytes: json['file_size_bytes'] as int? ?? 1024 * 1024,
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      badge: json['badge'] as String? ?? 'none',
      isFavorite: json['is_favorite'] as bool? ?? false,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      pageCount: json['page_count'] as int? ?? 1,
      slides: (json['slides'] as List<dynamic>? ?? [])
          .map((e) => MaterialSlideDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
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
      slides: slides.map((e) => e.toDomain()).toList(),
    );
  }
}
