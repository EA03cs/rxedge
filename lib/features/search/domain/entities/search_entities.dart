library;

/// Pure Dart Domain Entities for Global Search
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."

enum SearchResultCategory {
  lesson,
  libraryFile,
  objection,
}

class SearchResultItemEntity {
  final String id;
  final SearchResultCategory category;
  final String title;
  final String subtitle;
  final String badgeText;
  final String? targetRoute;
  final String? targetId;

  const SearchResultItemEntity({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    this.targetRoute,
    this.targetId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResultItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
