import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/storage/local_cache_service.dart';
import 'package:rxedge/features/search/data/repositories/search_repository_impl.dart';
import 'package:rxedge/features/search/domain/entities/search_entities.dart';

class MockLocalCacheService extends Mock implements LocalCacheService {}

void main() {
  late MockLocalCacheService mockCache;
  late SearchRepositoryImpl repository;

  setUp(() {
    mockCache = MockLocalCacheService();
    repository = SearchRepositoryImpl(cacheService: mockCache);
  });

  group('SearchRepositoryImpl Tests', () {
    test('search returns matching grouped items for Cardura', () async {
      final result = await repository.search('Cardura');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (map) {
          expect(map.containsKey(SearchResultCategory.lesson), isTrue);
          expect(map.containsKey(SearchResultCategory.libraryFile), isTrue);
          expect(map.containsKey(SearchResultCategory.objection), isTrue);
        },
        failure: (_) => fail('Expected search results'),
      );
    });

    test('search returns empty map when query has no matches', () async {
      final result = await repository.search('xyznonexistentquery');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (map) => expect(map.isEmpty, isTrue),
        failure: (_) => fail('Expected empty success map'),
      );
    });

    test('recent searches CRUD operations update cache', () async {
      when(() => mockCache.get<List<String>>('rxedge_recent_searches'))
          .thenReturn(['Cardura XL', 'Dosing']);
      when(() => mockCache.put<List<String>>('rxedge_recent_searches', any()))
          .thenAnswer((_) {});

      final recents = await repository.getRecentSearches();
      expect(recents.isSuccess, isTrue);

      await repository.addRecentSearch('AtorvaCare');
      verify(() => mockCache.put<List<String>>('rxedge_recent_searches', any())).called(1);

      await repository.clearRecentSearches();
      verify(() => mockCache.put<List<String>>('rxedge_recent_searches', [])).called(1);
    });
  });
}
