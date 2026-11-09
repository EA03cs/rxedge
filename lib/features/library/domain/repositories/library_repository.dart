library;

import '../../../../core/utils/result.dart';
import '../entities/material_item_entity.dart';

/// Abstract Contract for Resource Library Repository
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."
abstract class LibraryRepository {
  Future<Result<List<MaterialItemEntity>>> getMaterials({bool forceRefresh = false});
  Future<Result<MaterialItemEntity>> toggleFavorite(String id);
  Future<Result<MaterialItemEntity>> getMaterialById(String id);
  Future<Result<void>> markDownloaded(String id);
  Future<Result<void>> removeDownload(String id);
}
