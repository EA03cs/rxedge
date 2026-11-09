import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/search_entities.dart';

class RecentSearchesController extends AutoDisposeAsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final repo = ref.watch(searchRepositoryProvider);
    final result = await repo.getRecentSearches();
    return result.when(
      success: (list) => list,
      failure: (_) => [],
    );
  }

  Future<void> addSearch(String query) async {
    final repo = ref.read(searchRepositoryProvider);
    await repo.addRecentSearch(query);
    final result = await repo.getRecentSearches();
    result.when(
      success: (list) => state = AsyncValue.data(list),
      failure: (_) {},
    );
  }

  Future<void> removeSearch(String query) async {
    final repo = ref.read(searchRepositoryProvider);
    await repo.removeRecentSearch(query);
    final result = await repo.getRecentSearches();
    result.when(
      success: (list) => state = AsyncValue.data(list),
      failure: (_) {},
    );
  }

  Future<void> clearAll() async {
    final repo = ref.read(searchRepositoryProvider);
    await repo.clearRecentSearches();
    state = const AsyncValue.data([]);
  }
}

final recentSearchesProvider =
    AutoDisposeAsyncNotifierProvider<RecentSearchesController, List<String>>(
  RecentSearchesController.new,
);

class SearchResultsController
    extends AutoDisposeFamilyAsyncNotifier<Map<SearchResultCategory, List<SearchResultItemEntity>>?, String> {
  @override
  Future<Map<SearchResultCategory, List<SearchResultItemEntity>>?> build(String query) async {
    if (query.trim().isEmpty) {
      return null;
    }
    final repo = ref.watch(searchRepositoryProvider);
    final result = await repo.search(query);
    return result.when(
      success: (map) => map,
      failure: (f) => throw Exception(f.debugMessage ?? 'Search failed'),
    );
  }
}

final searchResultsProvider = AutoDisposeAsyncNotifierProviderFamily<
    SearchResultsController,
    Map<SearchResultCategory, List<SearchResultItemEntity>>?,
    String>(
  SearchResultsController.new,
);
