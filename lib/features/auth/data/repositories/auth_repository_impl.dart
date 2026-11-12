import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Production Authentication Repository Implementation
/// Integrates `D:\Backend\rxedge` Auth APIs (`/auth/login`, `/auth/logout`, `/auth/me`)
/// with secure token persistence.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource _localDatasource;
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl({
    required AuthLocalDatasource localDatasource,
    required AuthRemoteDatasource remoteDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource;

  @override
  Future<Result<UserEntity>> login({
    required String username,
    required String password,
    required bool keepSignedIn,
  }) async {
    AppLogger.d('AuthRepository.login initiated for: $username');

    final email = username.trim();
    if (email.isEmpty || password.trim().isEmpty) {
      return const Result.failure(
        ValidationFailure({'credentials': 'Required fields cannot be empty'}),
      );
    }

    try {
      final userDto = await _remoteDatasource.login(
        email: email,
        password: password,
      );

      // Always persist active access/refresh tokens so interceptor can attach Bearer & rotate.
      await _localDatasource.saveToken(userDto.token);
      if (userDto.refreshToken != null && userDto.refreshToken!.isNotEmpty) {
        await _localDatasource.saveRefreshToken(userDto.refreshToken!);
      }

      if (keepSignedIn) {
        await _localDatasource.saveUser(userDto);
      }

      final domainUser = userDto.toDomain();
      AppLogger.i('Authentication successful for: ${domainUser.displayName}');
      return Result.success(domainUser);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final refreshToken = await _localDatasource.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _remoteDatasource.logout(refreshToken: refreshToken);
        } catch (e) {
          AppLogger.w('Remote logout failed; clearing local session anyway: $e');
        }
      }
      await _localDatasource.clearToken();
      await _localDatasource.clearRefreshToken();
      await _localDatasource.clearUser();
      AppLogger.i('Session cleared successfully');
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(ExceptionMapper.map(e, st));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _localDatasource.getToken();
    if (token == null || token.isEmpty) return null;

    final cachedUser = await _localDatasource.getUser();
    try {
      final refreshToken = await _localDatasource.getRefreshToken();
      final remoteUser = await _remoteDatasource.getMe(
        currentToken: token,
        currentRefreshToken: refreshToken,
      );
      await _localDatasource.saveUser(remoteUser);
      return remoteUser.toDomain();
    } catch (_) {
      return cachedUser?.toDomain();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _localDatasource.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> isOnboardingCompleted() =>
      _localDatasource.isOnboardingCompleted();

  @override
  Future<void> setOnboardingCompleted() =>
      _localDatasource.setOnboardingCompleted();

  @override
  Future<bool> isBiometricEnabled() => _localDatasource.isBiometricEnabled();

  @override
  Future<void> setBiometricEnabled(bool enabled) =>
      _localDatasource.setBiometricEnabled(enabled);
}

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRemoteDatasourceImpl(dio);
});

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final cache = ref.watch(localCacheServiceProvider);
  return AuthLocalDatasourceImpl(
    secureStorage: secureStorage,
    cacheService: cache,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final local = ref.watch(authLocalDatasourceProvider);
  final remote = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(
    localDatasource: local,
    remoteDatasource: remote,
  );
});
