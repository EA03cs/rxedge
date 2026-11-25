import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/profile_entities.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _remoteDatasource;
  final ProfileLocalDatasource _localDatasource;
  UserProfileEntity? _memoryProfile;

  ProfileRepositoryImpl({
    required ProfileRemoteDatasource remoteDatasource,
    required ProfileLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  Future<Result<UserProfileEntity>> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _memoryProfile != null) {
      return Result.success(_memoryProfile!);
    }

    try {
      final savedPrefs = await _localDatasource.getSavedPreferences();
      if (!forceRefresh) {
        final cached = await _localDatasource.getCachedProfile();
        if (cached != null) {
          final domain = cached.toDomain();
          _memoryProfile = domain.copyWith(
            storageUsageBytes: _localDatasource.getStorageUsage(),
            notificationPreferences:
                savedPrefs?.toDomain() ?? domain.notificationPreferences,
          );
          return Result.success(_memoryProfile!);
        }
      }

      final remoteDto = await _remoteDatasource.getProfile();
      final NotificationPreferencesEntity resolvedPrefs;
      if (remoteDto.hasServerNotificationPreferences) {
        await _localDatasource.savePreferences(remoteDto.notificationPreferences);
        resolvedPrefs = remoteDto.notificationPreferences.toDomain();
      } else {
        resolvedPrefs =
            savedPrefs?.toDomain() ?? remoteDto.notificationPreferences.toDomain();
      }

      await _localDatasource.cacheProfile(remoteDto);
      final domain = remoteDto.toDomain();
      _memoryProfile = domain.copyWith(
        storageUsageBytes: _localDatasource.getStorageUsage(),
        notificationPreferences: resolvedPrefs,
      );
      return Result.success(_memoryProfile!);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<List<BadgeEntity>>> getMyBadges() async {
    try {
      final badgeDtos = await _remoteDatasource.getMyBadges();
      final badges = badgeDtos.map((b) => b.toDomain()).toList();
      if (_memoryProfile != null) {
        _memoryProfile = _memoryProfile!.copyWith(badges: badges);
      }
      return Result.success(badges);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> updateNotificationPreferences(
    NotificationPreferencesEntity preferences,
  ) async {
    try {
      final dto = NotificationPreferencesDto.fromDomain(preferences);
      await _remoteDatasource.updateNotificationPreferences(dto);
      await _localDatasource.savePreferences(dto);

      if (_memoryProfile != null) {
        _memoryProfile = _memoryProfile!.copyWith(notificationPreferences: preferences);
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> updateLanguagePreference(String languageCode) async {
    try {
      await _remoteDatasource.updateLanguagePreference(languageCode);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> clearCachedDownloads() async {
    try {
      await _localDatasource.clearDownloads();
      if (_memoryProfile != null) {
        _memoryProfile = _memoryProfile!.copyWith(storageUsageBytes: 0);
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<int>> getStorageUsage() async {
    try {
      final usage = _localDatasource.getStorageUsage();
      return Result.success(usage);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }
}

/// Riverpod Providers for Profile
final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ProfileRemoteDatasourceImpl(dio: dio);
});

final profileLocalDatasourceProvider = Provider<ProfileLocalDatasource>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return ProfileLocalDatasourceImpl(cacheService: cache);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ref.watch(profileRemoteDatasourceProvider);
  final local = ref.watch(profileLocalDatasourceProvider);
  return ProfileRepositoryImpl(
    remoteDatasource: remote,
    localDatasource: local,
  );
});
