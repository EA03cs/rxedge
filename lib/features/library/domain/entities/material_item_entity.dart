library;

/// Pure Dart Domain Entities for Resource Library
///
/// Follows Clean Architecture Dependency Rule:
/// "Domain has zero Flutter/Dio/Hive imports."

enum MaterialCategory {
  all,
  brochure,
  visualAid,
  edetail,
  marketing,
}

enum MaterialFileType {
  pdf,
  image,
  edetailSlides,
}

enum MaterialBadge {
  none,
  newRelease,
  updated,
}

sealed class DownloadState {
  const DownloadState();
}

final class NotDownloaded extends DownloadState {
  const NotDownloaded();
}

final class Downloading extends DownloadState {
  final double progress; // 0.0 to 1.0
  const Downloading(this.progress);
}

final class Downloaded extends DownloadState {
  final DateTime downloadedAt;
  const Downloaded(this.downloadedAt);
}

enum LibrarySortOption {
  newest,
  mostUsed,
  alphabetical,
}

enum LibraryShortcut {
  none,
  favorites,
  downloaded,
}

class MaterialSlide {
  final int slideNumber;
  final String title;
  final String headline;
  final List<String> clinicalKeyPoints;
  final List<String> bulletEvidence;
  final String? chartCaption;
  final String? imageUrl;

  const MaterialSlide({
    required this.slideNumber,
    required this.title,
    required this.headline,
    required this.clinicalKeyPoints,
    required this.bulletEvidence,
    this.chartCaption,
    this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialSlide &&
          runtimeType == other.runtimeType &&
          slideNumber == other.slideNumber &&
          title == other.title;

  @override
  int get hashCode => slideNumber.hashCode ^ title.hashCode;
}

class MaterialItemEntity {
  final String id;
  final String title;
  final String productName;
  final MaterialCategory category;
  final MaterialFileType fileType;
  final int fileSizeBytes;
  final DateTime updatedAt;
  final MaterialBadge badge;
  final bool isFavorite;
  final DownloadState downloadState;
  final int viewCount;
  final String description;
  final int pageCount;
  final List<MaterialSlide> slides;
  final String? fileUrl;
  final String? thumbnailUrl;
  final String? localFilePath;

  const MaterialItemEntity({
    required this.id,
    required this.title,
    required this.productName,
    required this.category,
    required this.fileType,
    required this.fileSizeBytes,
    required this.updatedAt,
    this.badge = MaterialBadge.none,
    this.isFavorite = false,
    this.downloadState = const NotDownloaded(),
    this.viewCount = 0,
    required this.description,
    this.pageCount = 1,
    this.slides = const [],
    this.fileUrl,
    this.thumbnailUrl,
    this.localFilePath,
  });

  bool get isDownloaded => downloadState is Downloaded;

  bool get isDownloading => downloadState is Downloading;

  double get downloadProgress =>
      downloadState is Downloading ? (downloadState as Downloading).progress : 0.0;

  String get formattedSize {
    if (fileSizeBytes < 1024 * 1024) {
      final kb = (fileSizeBytes / 1024).toStringAsFixed(0);
      return '$kb KB';
    }
    final mb = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
    return '$mb MB';
  }

  MaterialItemEntity copyWith({
    String? id,
    String? title,
    String? productName,
    MaterialCategory? category,
    MaterialFileType? fileType,
    int? fileSizeBytes,
    DateTime? updatedAt,
    MaterialBadge? badge,
    bool? isFavorite,
    DownloadState? downloadState,
    int? viewCount,
    String? description,
    int? pageCount,
    List<MaterialSlide>? slides,
    String? fileUrl,
    String? thumbnailUrl,
    String? localFilePath,
  }) {
    return MaterialItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      updatedAt: updatedAt ?? this.updatedAt,
      badge: badge ?? this.badge,
      isFavorite: isFavorite ?? this.isFavorite,
      downloadState: downloadState ?? this.downloadState,
      viewCount: viewCount ?? this.viewCount,
      description: description ?? this.description,
      pageCount: pageCount ?? this.pageCount,
      slides: slides ?? this.slides,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isFavorite == other.isFavorite &&
          downloadState.runtimeType == other.downloadState.runtimeType;

  @override
  int get hashCode => id.hashCode ^ isFavorite.hashCode ^ downloadState.runtimeType.hashCode;
}
