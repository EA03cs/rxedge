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
  final int? quarter;
  final int? year;

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
    this.quarter,
    this.year,
  });

  static const List<String> _binaryFileExtensions = [
    '.pdf',
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
    '.gif',
    '.bmp',
    '.svg',
    '.mp4',
    '.mov',
    '.mp3',
    '.m4a',
    '.zip',
    '.ppt',
    '.pptx',
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
    '.bin',
  ];

  bool get hasFileUrl => fileUrl != null && fileUrl!.trim().isNotEmpty;

  bool get isGoogleDriveOrDocsUrl {
    final raw = fileUrl?.trim();
    if (raw == null || raw.isEmpty) return false;
    final uri = Uri.tryParse(raw);
    final host = uri?.host.toLowerCase() ?? '';
    if (host == 'drive.google.com' ||
        host.endsWith('.drive.google.com') ||
        host == 'docs.google.com' ||
        host.endsWith('.docs.google.com')) {
      return true;
    }
    final lower = raw.toLowerCase();
    return lower.contains('drive.google.com') ||
        lower.contains('docs.google.com');
  }

  /// True only when [fileUrl] points to a direct downloadable binary file
  /// rather than an external viewer page (e.g. Google Drive/Docs or web URL).
  bool get hasDirectDownloadUrl {
    final raw = fileUrl?.trim();
    if (raw == null || raw.isEmpty) return false;
    if (isGoogleDriveOrDocsUrl) return false;

    final uri = Uri.tryParse(raw);
    if (uri == null) return false;
    if (uri.hasScheme && uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }

    final path = uri.path.toLowerCase();
    if (_binaryFileExtensions.any(path.endsWith)) {
      return true;
    }
    return path.contains('/uploads/');
  }

  /// True when a URL exists, but is an external Drive/Docs link or lacks a
  /// direct downloadable binary file URL.
  bool get isExternalOnlineLink => hasFileUrl && !hasDirectDownloadUrl;

  bool get isDownloaded =>
      downloadState is Downloaded &&
      localFilePath != null &&
      localFilePath!.trim().isNotEmpty;

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
    bool clearLocalFilePath = false,
    int? quarter,
    int? year,
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
      localFilePath:
          clearLocalFilePath ? null : (localFilePath ?? this.localFilePath),
      quarter: quarter ?? this.quarter,
      year: year ?? this.year,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isFavorite == other.isFavorite &&
          localFilePath == other.localFilePath &&
          downloadState.runtimeType == other.downloadState.runtimeType;

  @override
  int get hashCode =>
      id.hashCode ^
      isFavorite.hashCode ^
      localFilePath.hashCode ^
      downloadState.runtimeType.hashCode;
}
