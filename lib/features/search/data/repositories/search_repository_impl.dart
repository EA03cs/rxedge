import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../../challenges/data/repositories/challenges_repository_impl.dart';
import '../../../challenges/domain/repositories/challenges_repository.dart';
import '../../../learn/data/repositories/learn_repository_impl.dart';
import '../../../learn/domain/repositories/learn_repository.dart';
import '../../../library/data/repositories/library_repository_impl.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final Dio? _dio;
  final LocalCacheService _cacheService;
  final LearnRepository? _learnRepository;
  final LibraryRepository? _libraryRepository;
  final ChallengesRepository? _challengesRepository;
  static const String _recentSearchesKey = 'rxedge_recent_searches';

  SearchRepositoryImpl({
    Dio? dio,
    required LocalCacheService cacheService,
    LearnRepository? learnRepository,
    LibraryRepository? libraryRepository,
    ChallengesRepository? challengesRepository,
  })  : _dio = dio,
        _cacheService = cacheService,
        _learnRepository = learnRepository,
        _libraryRepository = libraryRepository,
        _challengesRepository = challengesRepository;

  static const List<SearchResultItemEntity> _searchIndex = [
    // Products
    SearchResultItemEntity(
      id: 'prod_rohto_dry_aid',
      category: SearchResultCategory.lesson,
      title: 'Rohto Dry Aid',
      subtitle: 'Advanced lipid-stabilizing eye drops for severe dry eye • 4 min read',
      badgeText: 'Dry Eye Relief',
      targetRoute: '/learn/product',
      targetId: 'prod-rohto-dry-aid',
    ),
    SearchResultItemEntity(
      id: 'prod_rohto_cool',
      category: SearchResultCategory.lesson,
      title: 'Rohto Cool',
      subtitle: 'Fast-acting cooling relief for redness & digital eye fatigue • 5 min read',
      badgeText: 'Redness Relief',
      targetRoute: '/learn/product',
      targetId: 'prod-rohto-cool',
    ),
    SearchResultItemEntity(
      id: 'prod_rohto_aqua',
      category: SearchResultCategory.lesson,
      title: 'Rohto Aqua',
      subtitle: 'Gentle moisturizing drops for sensitive eyes & contact lens wearers • 4 min read',
      badgeText: 'Sensitive Eyes',
      targetRoute: '/learn/product',
      targetId: 'prod-rohto-aqua',
    ),

    // Lessons
    SearchResultItemEntity(
      id: 'sr_les_1',
      category: SearchResultCategory.lesson,
      title: 'Rohto Dry Aid Tearshield Technology & Triple Layer Restoration',
      subtitle: 'Restoration of lipid, aqueous, and mucin layers • 4 min read',
      badgeText: 'Rohto Dry Aid',
      targetRoute: '/learn/lesson',
      targetId: 'prod-rohto-dry-aid',
    ),
    SearchResultItemEntity(
      id: 'sr_les_2',
      category: SearchResultCategory.lesson,
      title: 'Rohto Cool Instant Ocular Refreshment & Redness Relief',
      subtitle: 'Targeted cooling sensation for digital screen fatigue • 5 min read',
      badgeText: 'Rohto Cool',
      targetRoute: '/learn/lesson',
      targetId: 'prod-rohto-cool',
    ),
    SearchResultItemEntity(
      id: 'sr_les_3',
      category: SearchResultCategory.lesson,
      title: 'Rohto Aqua Gentle Moisturizing for Sensitive Corneas',
      subtitle: 'Preservative-free formulation for daily ocular lubrication • 4 min read',
      badgeText: 'Rohto Aqua',
      targetRoute: '/learn/lesson',
      targetId: 'prod-rohto-aqua',
    ),

    // Library Files
    SearchResultItemEntity(
      id: 'sr_lib_1',
      category: SearchResultCategory.libraryFile,
      title: 'Rohto Dry Aid 2026 Clinical Monograph',
      subtitle: 'Official prescribing information, tear osmolarity tables (PDF, 4.2 MB)',
      badgeText: 'PDF',
      targetRoute: '/library',
      targetId: 'mat_rohto_mono',
    ),
    SearchResultItemEntity(
      id: 'sr_lib_2',
      category: SearchResultCategory.libraryFile,
      title: 'Rohto Dry Aid Interactive E-Detailing Deck',
      subtitle: '7-slide doctor presentation with Tearshield animation (E-Detail, 12.8 MB)',
      badgeText: 'E-Detail',
      targetRoute: '/library',
      targetId: 'mat_rohto_edetail',
    ),
    SearchResultItemEntity(
      id: 'sr_lib_3',
      category: SearchResultCategory.libraryFile,
      title: 'Rohto Cool Eye Drops Official Visual Aid',
      subtitle: 'Clinical visual aid for ophthalmology clinic visits (Brochure, 2.4 MB)',
      badgeText: 'Visual Aid',
      targetRoute: '/library',
      targetId: 'mat_rohto_cool_va',
    ),

    // Doctor Objections
    SearchResultItemEntity(
      id: 'sr_obj_1',
      category: SearchResultCategory.objection,
      title: 'Doctor asks about Rohto cooling sensation and ocular safety',
      subtitle: 'Response: Clarify pharmaceutical-grade menthol soothing meibomian glands',
      badgeText: 'Rohto Cool',
      targetRoute: '/challenges',
      targetId: 'ch_rohto_dry_aid_nov',
    ),
    SearchResultItemEntity(
      id: 'sr_obj_2',
      category: SearchResultCategory.objection,
      title: 'Doctor questions advantage of Tearshield over standard saline drops',
      subtitle: 'Response: Cite 12h lipid stabilization trial vs 15-minute saline washout',
      badgeText: 'Objection',
      targetRoute: '/challenges',
      targetId: 'ch_rohto_dry_aid_nov',
    ),
    SearchResultItemEntity(
      id: 'sr_obj_3',
      category: SearchResultCategory.objection,
      title: 'Doctor concern regarding temporary vision blurring after instillation',
      subtitle: 'Response: Highlight non-blurring micro-emulsion for immediate screen use',
      badgeText: 'Objection',
      targetRoute: '/challenges',
      targetId: 'ch_rohto_dry_aid_nov',
    ),
  ];

  @override
  Future<Result<Map<SearchResultCategory, List<SearchResultItemEntity>>>> search(String query) async {
    final trimmedQuery = query.trim();
    final cleanQuery = trimmedQuery.toLowerCase();
    if (cleanQuery.isEmpty) {
      return const Result.success({});
    }

    if (_dio != null) {
      try {
        final response = await _dio.get<dynamic>(
          ApiEndpoints.search,
          queryParameters: {'q': trimmedQuery},
        );
        final payload = ApiResponseParser.unwrapMap(response.data);
        final grouped = _mapServerSearchPayload(payload);
        if (grouped.isNotEmpty) {
          return Result.success(grouped);
        }
      } catch (_) {
        // Fall through to local repository/cache aggregation if offline or endpoint unreachable.
      }
    }

    final liveItems = <SearchResultItemEntity>[];

    if (_learnRepository != null ||
        _libraryRepository != null ||
        _challengesRepository != null) {
      if (_learnRepository != null) {
        final productsRes = await _learnRepository.getProducts();
        productsRes.when(
          success: (products) {
            for (final prod in products) {
              // Add product itself as a first-class search result
              liveItems.add(
                SearchResultItemEntity(
                  id: 'prod_${prod.id}',
                  category: SearchResultCategory.lesson,
                  title: prod.name,
                  subtitle: prod.positioning.keyMessage,
                  badgeText: prod.therapeuticArea,
                  targetRoute: '/learn/product',
                  targetId: prod.id,
                ),
              );

              for (final lesson in prod.lessons) {
                liveItems.add(
                  SearchResultItemEntity(
                    id: 'lesson_${lesson.id}',
                    category: SearchResultCategory.lesson,
                    title: lesson.title,
                    subtitle: lesson.sections.firstOrNull?.keyTakeaway ??
                        lesson.sections.firstOrNull?.content ??
                        prod.therapeuticArea,
                    badgeText: prod.name,
                    targetRoute: '/learn/lesson',
                    targetId: lesson.id,
                  ),
                );
              }
              for (final comp in prod.competitors) {
                liveItems.add(
                  SearchResultItemEntity(
                    id: 'comp_${comp.id}',
                    category: SearchResultCategory.objection,
                    title: comp.competitorName,
                    subtitle: '${comp.theirClaim} • ${comp.howToRespond}',
                    badgeText: prod.name,
                    targetRoute: '/challenges',
                    targetId: comp.id,
                  ),
                );
              }
            }
          },
          failure: (_) {},
        );
      }

      if (_libraryRepository != null) {
        final materialsRes = await _libraryRepository.getMaterials();
        materialsRes.when(
          success: (materials) {
            for (final mat in materials) {
              liveItems.add(
                SearchResultItemEntity(
                  id: 'mat_${mat.id}',
                  category: SearchResultCategory.libraryFile,
                  title: mat.title,
                  subtitle: '${mat.productName} • ${mat.formattedSize}',
                  badgeText: mat.productName,
                  targetRoute: '/library',
                  targetId: mat.id,
                ),
              );
            }
          },
          failure: (_) {},
        );
      }

      if (_challengesRepository != null) {
        final objRes = await _challengesRepository.getObjectionOfTheMonth();
        objRes.when(
          success: (obj) {
            if (obj.doctorQuote.trim().isNotEmpty) {
              liveItems.add(
                SearchResultItemEntity(
                  id: 'obj_${obj.id}',
                  category: SearchResultCategory.objection,
                  title: obj.doctorQuote,
                  subtitle: obj.recommendedResponse,
                  badgeText: obj.productConcerned,
                  targetRoute: '/challenges',
                  targetId: obj.id,
                ),
              );
            }
          },
          failure: (_) {},
        );
      }
    }

    final source = liveItems.isNotEmpty ? liveItems : _searchIndex;

    final matches = source.where((item) {
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

  Map<SearchResultCategory, List<SearchResultItemEntity>> _mapServerSearchPayload(
    Map<String, dynamic> payload,
  ) {
    final grouped = <SearchResultCategory, List<SearchResultItemEntity>>{};

    void addItem(SearchResultItemEntity item) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final products = (payload['products'] as List<dynamic>? ?? const []);
    for (final raw in products.whereType<Map<dynamic, dynamic>>()) {
      final map = Map<String, dynamic>.from(raw);
      final id = map['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      addItem(
        SearchResultItemEntity(
          id: 'prod_$id',
          category: SearchResultCategory.lesson,
          title: map['name']?.toString() ?? '',
          subtitle: map['keyMessage']?.toString() ?? map['description']?.toString() ?? '',
          badgeText: map['therapeuticAreaName']?.toString() ??
              map['therapeuticArea']?.toString() ??
              '',
          targetRoute: '/learn/product',
          targetId: id,
        ),
      );
    }

    final lessons = (payload['lessons'] as List<dynamic>? ?? const []);
    for (final raw in lessons.whereType<Map<dynamic, dynamic>>()) {
      final map = Map<String, dynamic>.from(raw);
      final id = map['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      addItem(
        SearchResultItemEntity(
          id: 'lesson_$id',
          category: SearchResultCategory.lesson,
          title: map['title']?.toString() ?? '',
          subtitle: map['summary']?.toString() ?? '',
          badgeText: map['productName']?.toString() ?? '',
          targetRoute: '/learn/lesson',
          targetId: map['productId']?.toString() ?? id,
        ),
      );
    }

    final materials = (payload['materials'] as List<dynamic>? ?? const []);
    for (final raw in materials.whereType<Map<dynamic, dynamic>>()) {
      final map = Map<String, dynamic>.from(raw);
      final id = map['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      addItem(
        SearchResultItemEntity(
          id: 'mat_$id',
          category: SearchResultCategory.libraryFile,
          title: map['title']?.toString() ?? '',
          subtitle: map['description']?.toString() ?? '',
          badgeText: map['productName']?.toString() ?? map['type']?.toString() ?? '',
          targetRoute: '/library',
          targetId: id,
        ),
      );
    }

    final competitors = (payload['competitors'] as List<dynamic>? ?? const []);
    for (final raw in competitors.whereType<Map<dynamic, dynamic>>()) {
      final map = Map<String, dynamic>.from(raw);
      final id = map['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final claims = map['claims']?.toString() ?? '';
      final responseText = map['recommendedResponse']?.toString() ?? '';
      addItem(
        SearchResultItemEntity(
          id: 'comp_$id',
          category: SearchResultCategory.objection,
          title: map['name']?.toString() ?? '',
          subtitle: [claims, responseText].where((s) => s.isNotEmpty).join(' • '),
          badgeText: map['productName']?.toString() ?? map['activeIngredient']?.toString() ?? '',
          targetRoute: '/challenges',
          targetId: map['productId']?.toString() ?? id,
        ),
      );
    }

    return grouped;
  }

  @override
  Future<Result<List<String>>> getRecentSearches() async {
    final list = _cacheService.get<List<String>>(_recentSearchesKey) ??
        const <String>[];
    return Result.success(list);
  }

  @override
  Future<Result<void>> addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return const Result.success(null);

    final current = _cacheService.get<List<String>>(_recentSearchesKey) ??
        const <String>[];

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
  final dio = ref.watch(dioClientProvider);
  final cache = ref.watch(localCacheServiceProvider);
  final learnRepo = ref.watch(learnRepositoryProvider);
  final libraryRepo = ref.watch(libraryRepositoryProvider);
  final challengesRepo = ref.watch(challengesRepositoryProvider);
  return SearchRepositoryImpl(
    dio: dio,
    cacheService: cache,
    learnRepository: learnRepo,
    libraryRepository: libraryRepo,
    challengesRepository: challengesRepo,
  );
});
