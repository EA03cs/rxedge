import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final LocalCacheService _cacheService;
  static const String _recentSearchesKey = 'rxedge_recent_searches';

  SearchRepositoryImpl({required LocalCacheService cacheService})
      : _cacheService = cacheService;

  static const List<SearchResultItemEntity> _searchIndex = [
    // Lessons
    SearchResultItemEntity(
      id: 'sr_les_1',
      category: SearchResultCategory.lesson,
      title: 'Cardura XL GITS Absorption Curve & Zero-Order Delivery',
      subtitle: 'Elimination of morning peak-to-trough spikes • 4 min read',
      badgeText: 'Cardura XL',
      targetRoute: '/learn',
      targetId: 'prod_cardura',
    ),
    SearchResultItemEntity(
      id: 'sr_les_2',
      category: SearchResultCategory.lesson,
      title: 'AtorvaCare Lipid Lowering Dosing Guide & Titration',
      subtitle: 'Evidence-based LDL-C targets in high CV risk patients • 6 min read',
      badgeText: 'AtorvaCare',
      targetRoute: '/learn',
      targetId: 'prod_atorvacare',
    ),
    SearchResultItemEntity(
      id: 'sr_les_3',
      category: SearchResultCategory.lesson,
      title: 'Cardura XL vs Amlodipine: 24h ABPM Night Dipping',
      subtitle: 'ASCOT-BPLA clinical evidence and peripheral edema rates • 5 min read',
      badgeText: 'Cardura XL',
      targetRoute: '/learn',
      targetId: 'prod_cardura',
    ),

    // Library Files
    SearchResultItemEntity(
      id: 'sr_lib_1',
      category: SearchResultCategory.libraryFile,
      title: 'Cardura XL 2026 Clinical Monograph',
      subtitle: 'Official prescribing information, pharmacokinetic tables (PDF, 4.2 MB)',
      badgeText: 'PDF',
      targetRoute: '/library',
      targetId: 'mat_cardura_mono',
    ),
    SearchResultItemEntity(
      id: 'sr_lib_2',
      category: SearchResultCategory.libraryFile,
      title: 'Cardura XL Interactive E-Detailing Deck',
      subtitle: '7-slide doctor presentation with GITS interactive animation (E-Detail, 12.8 MB)',
      badgeText: 'E-Detail',
      targetRoute: '/library',
      targetId: 'mat_cardura_edetail',
    ),
    SearchResultItemEntity(
      id: 'sr_lib_3',
      category: SearchResultCategory.libraryFile,
      title: 'AtorvaCare Primary Prevention Visual Aid',
      subtitle: 'Laminated clinical visual aid for cardiology & internal clinic visits (Brochure, 2.4 MB)',
      badgeText: 'Visual Aid',
      targetRoute: '/library',
      targetId: 'mat_atorva_va',
    ),

    // Doctor Objections
    SearchResultItemEntity(
      id: 'sr_obj_1',
      category: SearchResultCategory.objection,
      title: 'Doctor skeptical about Cardura XL morning orthostatic hypotension',
      subtitle: 'Response: Clarify GITS zero-order delivery vs generic alpha-blocker peaks',
      badgeText: 'Cardura XL',
      targetRoute: '/challenges',
      targetId: 'ch_cardio_blitz',
    ),
    SearchResultItemEntity(
      id: 'sr_obj_2',
      category: SearchResultCategory.objection,
      title: 'Doctor claims amlodipine produces identical 24h blood pressure dipping',
      subtitle: 'Response: Cite ABPM nocturnal control trials without pedal edema incidence',
      badgeText: 'Objection',
      targetRoute: '/challenges',
      targetId: 'ch_cardio_blitz',
    ),
    SearchResultItemEntity(
      id: 'sr_obj_3',
      category: SearchResultCategory.objection,
      title: 'Cost concern vs generic atorvastatin 40mg',
      subtitle: 'Response: Emphasize micronized API bioavailability and proven tolerability',
      badgeText: 'Objection',
      targetRoute: '/challenges',
      targetId: 'ch_cardio_blitz',
    ),
  ];

  @override
  Future<Result<Map<SearchResultCategory, List<SearchResultItemEntity>>>> search(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return const Result.success({});
    }

    await Future<void>.delayed(const Duration(milliseconds: 90));

    final matches = _searchIndex.where((item) {
      final inTitle = item.title.toLowerCase().contains(cleanQuery);
      final inSubtitle = item.subtitle.toLowerCase().contains(cleanQuery);
      final inBadge = item.badgeText.toLowerCase().contains(cleanQuery);
      return inTitle || inSubtitle || inBadge;
    }).toList();

    final grouped = <SearchResultCategory, List<SearchResultItemEntity>>{};
    for (final item in matches) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Result.success(grouped);
  }

  @override
  Future<Result<List<String>>> getRecentSearches() async {
    final list = _cacheService.get<List<String>>(_recentSearchesKey) ??
        ['Cardura XL', 'GITS delivery', 'AtorvaCare', 'Amlodipine'];
    return Result.success(list);
  }

  @override
  Future<Result<void>> addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return const Result.success(null);

    final current = _cacheService.get<List<String>>(_recentSearchesKey) ??
        ['Cardura XL', 'GITS delivery', 'AtorvaCare', 'Amlodipine'];

    final updated = List<String>.from(current);
    updated.remove(clean);
    updated.insert(0, clean);
    if (updated.length > 8) {
      updated.removeLast();
    }
    _cacheService.put<List<String>>(_recentSearchesKey, updated);
    return const Result.success(null);
  }

  @override
  Future<Result<void>> removeRecentSearch(String query) async {
    final current = _cacheService.get<List<String>>(_recentSearchesKey) ?? [];
    final updated = List<String>.from(current)..remove(query);
    _cacheService.put<List<String>>(_recentSearchesKey, updated);
    return const Result.success(null);
  }

  @override
  Future<Result<void>> clearRecentSearches() async {
    _cacheService.put<List<String>>(_recentSearchesKey, []);
    return const Result.success(null);
  }
}

/// Riverpod Providers for Search
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return SearchRepositoryImpl(cacheService: cache);
});
