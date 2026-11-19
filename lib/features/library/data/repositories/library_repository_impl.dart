import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/material_item_entity.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_datasource.dart';
import '../datasources/library_remote_datasource.dart';
import '../models/material_item_dto.dart';

/// Repository Implementation for Resource Library
///
/// Follows Architectural Contracts:
/// 1. Repositories return Result, never throw into the UI.
/// 2. Caches remote data (stale-while-revalidate).
/// 3. Locally persists user overrides (Favorites and Downloaded states).
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDatasource _remoteDatasource;
  final LibraryLocalDatasource _localDatasource;

  // In-memory working cache
  List<MaterialItemEntity>? _memoryItems;

  static const List<MaterialItemDto> rohtoMaterials = [
    MaterialItemDto(
      id: 'mat_rohto_dry_aid_brochure',
      title: 'Rohto Dry Aid Official Clinical Brochure',
      productName: 'Rohto Dry Aid',
      category: 'brochure',
      fileType: 'pdf',
      fileSizeBytes: 4200000,
      updatedAt: '2026-11-18T10:00:00Z',
      badge: 'updated',
      isFavorite: true,
      isDownloaded: false,
      viewCount: 185,
      pageCount: 8,
      fileUrl:
          'https://drive.google.com/file/d/1jemssfgDhAoDZD1I2OIV9fXaZe3ns-n/view?usp=drive_link',
      description:
          'Comprehensive clinical brochure detailing Tearshield Technology, 12-hour symptom relief, and comparison with Systane Ultra.',
    ),
    MaterialItemDto(
      id: 'mat_rohto_cool_brochure',
      title: 'Rohto Cool Eye Drops Official Brochure',
      productName: 'Rohto Cool',
      category: 'brochure',
      fileType: 'pdf',
      fileSizeBytes: 3100000,
      updatedAt: '2026-11-18T11:00:00Z',
      badge: 'new',
      isFavorite: false,
      isDownloaded: false,
      viewCount: 120,
      pageCount: 6,
      fileUrl:
          'https://drive.google.com/file/d/2NVbg1Qevuv7AE_XiG7Vg2VZZV/view?usp=sharing',
      description:
          'Cooling and refreshing eye drop clinical materials, contact lens wearers guidance, and mineral restoration formula.',
    ),
    MaterialItemDto(
      id: 'mat_rohto_aqua_deck',
      title: 'Rohto Aqua Gentle Lubricating Detailing Deck',
      productName: 'Rohto Aqua',
      category: 'edetail',
      fileType: 'edetail',
      fileSizeBytes: 5400000,
      updatedAt: '2026-11-18T12:00:00Z',
      badge: 'new',
      isFavorite: false,
      isDownloaded: false,
      viewCount: 95,
      pageCount: 5,
      description:
          'Gentle lubricating e-detailing deck for LASIK patients and contact lens-associated dry eye (CLADE).',
    ),
  ];

  List<MaterialItemDto> _ensureRohtoMaterials(List<MaterialItemDto> dtos) {
    final filtered = dtos.where((m) {
      final p = m.productName.toLowerCase();
      final t = m.title.toLowerCase();
      return !p.contains('cardura') &&
          !p.contains('atorva') &&
          !p.contains('gluco') &&
          !t.contains('cardura') &&
          !t.contains('atorva') &&
          !t.contains('gluco');
    }).toList();

    final hasRohto = filtered.any((m) =>
        m.productName.toLowerCase().contains('rohto') ||
        m.title.toLowerCase().contains('rohto'));
    if (hasRohto) return filtered;
    return [...rohtoMaterials, ...filtered];
  }

  LibraryRepositoryImpl({
    required LibraryRemoteDatasource remoteDatasource,
    required LibraryLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<List<MaterialItemEntity>>> getMaterials({bool forceRefresh = false}) async {
    // 1. If in-memory items exist and not forcing refresh, return immediately
    if (!forceRefresh && _memoryItems != null && _memoryItems!.isNotEmpty) {
      return Result.success(_memoryItems!);
    }

    // 2. Check fresh local cache
    if (!forceRefresh && _localDatasource.isCacheFresh()) {
      try {
        final cached = await _localDatasource.getCachedMaterials();
        if (cached != null && cached.isNotEmpty) {
          AppLogger.d('Returning fresh cached Library materials');
          final ensured = _ensureRohtoMaterials(cached);
          final domainItems = await _mergeWithLocalOverrides(ensured);
          _memoryItems = domainItems;
          return Result.success(domainItems);
        }
      } catch (e) {
        AppLogger.w('Failed reading cached materials, falling back: $e');
      }
    }

    // 3. Fetch from remote
    try {
      AppLogger.d('Fetching remote Library materials...');
      final remoteList = await _remoteDatasource.getMaterials();
      final ensured = _ensureRohtoMaterials(remoteList);
      await _localDatasource.cacheMaterials(ensured);

      final domainItems = await _mergeWithLocalOverrides(ensured);
      _memoryItems = domainItems;
      return Result.success(domainItems);
    } catch (e) {
      AppLogger.w('Remote library fetch failed, attempting stale fallback', error: e);

      // Stale cache fallback
      try {
        final staleCache = await _localDatasource.getCachedMaterials();
        if (staleCache != null && staleCache.isNotEmpty) {
          final ensured = _ensureRohtoMaterials(staleCache);
          final domainItems = await _mergeWithLocalOverrides(ensured);
          _memoryItems = domainItems;
          return Result.success(domainItems);
        }
      } catch (_) {}

      final failure = ExceptionMapper.map(e);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<MaterialItemEntity>> toggleFavorite(String id) async {
    try {
      final favorites = await _localDatasource.getFavorites();
      final isFav = favorites.contains(id);

      final updatedFavorites = Set<String>.from(favorites);
      if (isFav) {
        updatedFavorites.remove(id);
      } else {
        updatedFavorites.add(id);
      }
      await _localDatasource.saveFavorites(updatedFavorites);

      // Update in-memory items
      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          final updated = _memoryItems![index].copyWith(isFavorite: !isFav);
          _memoryItems![index] = updated;
          return Result.success(updated);
        }
      }

      // If not in memory, get item by ID
      final itemResult = await getMaterialById(id);
      return itemResult.when(
        success: (item) => Result.success(item.copyWith(isFavorite: !isFav)),
        failure: (f) => Result.failure(f),
      );
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> markDownloaded(String id) async {
    try {
      final downloaded = await _localDatasource.getDownloadedIds();
      final updatedDownloaded = Set<String>.from(downloaded)..add(id);
      await _localDatasource.saveDownloadedIds(updatedDownloaded);

      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          _memoryItems![index] = _memoryItems![index].copyWith(
            downloadState: Downloaded(DateTime.now()),
          );
        }
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> removeDownload(String id) async {
    try {
      final downloaded = await _localDatasource.getDownloadedIds();
      final updatedDownloaded = Set<String>.from(downloaded)..remove(id);
      await _localDatasource.saveDownloadedIds(updatedDownloaded);

      if (_memoryItems != null) {
        final index = _memoryItems!.indexWhere((item) => item.id == id);
        if (index != -1) {
          _memoryItems![index] = _memoryItems![index].copyWith(
            downloadState: const NotDownloaded(),
          );
        }
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<MaterialItemEntity>> getMaterialById(String id) async {
    if (_memoryItems != null) {
      final found = _memoryItems!.where((item) => item.id == id);
      if (found.isNotEmpty) {
        return Result.success(found.first);
      }
    }

    final allResult = await getMaterials();
    return allResult.when(
      success: (list) {
        final found = list.where((item) => item.id == id);
        if (found.isNotEmpty) {
          return Result.success(found.first);
        }
        return Result.failure(ExceptionMapper.map(Exception('Material not found: $id')));
      },
      failure: (f) => Result.failure(f),
    );
  }

  Future<List<MaterialItemEntity>> _mergeWithLocalOverrides(
    List<MaterialItemDto> dtoList,
  ) async {
    final favorites = await _localDatasource.getFavorites();
    final downloaded = await _localDatasource.getDownloadedIds();

    return dtoList.map((dto) {
      final entity = dto.toDomain();
      // Apply local overrides if present
      final hasLocalFav = favorites.isNotEmpty ? favorites.contains(entity.id) : entity.isFavorite;
      final hasLocalDl = downloaded.isNotEmpty ? downloaded.contains(entity.id) : entity.isDownloaded;

      return entity.copyWith(
        isFavorite: hasLocalFav,
        downloadState: hasLocalDl ? Downloaded(DateTime.now()) : const NotDownloaded(),
      );
    }).toList();
  }
}

/// Riverpod Providers for Library Data Layer
final libraryRemoteDatasourceProvider = Provider<LibraryRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return LibraryRemoteDatasourceImpl(dio: dio);
});

final libraryLocalDatasourceProvider = Provider<LibraryLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return LibraryLocalDatasourceImpl(cache);
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final remote = ref.watch(libraryRemoteDatasourceProvider);
  final local = ref.watch(libraryLocalDatasourceProvider);
  return LibraryRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
