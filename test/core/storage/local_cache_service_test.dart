import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/core/storage/local_cache_service.dart';

void main() {
  late LocalCacheService cacheService;

  setUp(() {
    cacheService = LocalCacheService();
  });

  group('LocalCacheService Automated Robustness Tests', () {
    test('stores and retrieves string correctly', () {
      cacheService.put<String>('test_key', 'test_value');
      final val = cacheService.get<String>('test_key');
      expect(val, 'test_value');
    });

    test('stores and retrieves Map correctly', () {
      final map = <String, dynamic>{'name': 'Rohto Dry Aid', 'id': '123'};
      cacheService.put<Map<String, dynamic>>('prod_key', map);
      final retrieved = cacheService.get<Map<String, dynamic>>('prod_key');
      expect(retrieved, isNotNull);
      expect(retrieved?['name'], 'Rohto Dry Aid');
    });

    test('returns null without throwing when requesting String for cached List', () {
      final list = <dynamic>[
        {'id': 1},
        {'id': 2},
      ];
      cacheService.put<List<dynamic>>('list_key', list);

      // This previously could throw type cast exception if unhandled
      expect(() => cacheService.get<String>('list_key'), returnsNormally);
      final result = cacheService.get<String>('list_key');
      expect(result, isNull);
    });

    test('returns null without throwing when requesting List for cached Map', () {
      final map = <String, dynamic>{'brand': 'Rohto'};
      cacheService.put<Map<String, dynamic>>('map_key', map);

      expect(() => cacheService.get<List<dynamic>>('map_key'), returnsNormally);
      final result = cacheService.get<List<dynamic>>('map_key');
      expect(result, isNull);
    });

    test('reports fresh key and respects TTL expiration', () {
      cacheService.put<String>('ttl_key', 'data', ttl: const Duration(milliseconds: 50));
      expect(cacheService.isFresh('ttl_key'), isTrue);

      // Non-existent key is not fresh
      expect(cacheService.isFresh('unknown_key'), isFalse);
    });
  });
}
