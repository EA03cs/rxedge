import '../../../../core/utils/result.dart';
import '../entities/search_entities.dart';

/// Global Search Repository Contract
abstract class SearchRepository {
  Future<Result<Map<SearchResultCategory, List<SearchResultItemEntity>>>> search(String query);
  Future<Result<List<String>>> getRecentSearches();
  Future<Result<void>> addRecentSearch(String query);
  Future<Result<void>> removeRecentSearch(String query);
  Future<Result<void>> clearRecentSearches();
}
