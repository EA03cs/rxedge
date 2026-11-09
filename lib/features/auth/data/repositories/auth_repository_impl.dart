import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_dto.dart';

/// Mock Authentication Repository Implementation behind abstract contract
///
/// Follows Architectural Contract:
/// 1. Repositories return `Result<T>`, never throw into the UI.
/// 2. Handles every state (loading, wrong credentials, no connection).
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource _localDatasource;

  AuthRepositoryImpl({
    required AuthLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  @override
  Future<Result<UserEntity>> login({
    required String username,
    required String password,
    required bool keepSignedIn,
  }) async {
    AppLogger.d('AuthRepository.login initiated for: $username');

    // Simulate realistic network delay
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final trimmedUser = username.trim();
    final trimmedPass = password.trim();

    // 1. Validation check
    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      final errors = <String, String>{};
      if (trimmedUser.isEmpty) errors['username'] = 'Work Email or Employee ID is required';
      if (trimmedPass.isEmpty) errors['password'] = 'Password is required';
      return Result.failure(ValidationFailure(errors, debugMessage: 'Required fields missing'));
    }

    // 2. Simulated offline network failure
    if (trimmedUser.toLowerCase().contains('offline') || trimmedPass.toLowerCase().contains('offline')) {
      return const Result.failure(
        NetworkFailure(debugMessage: 'Simulated connection failure during login'),
      );
    }

    // 3. Simulated credential failure
    if (trimmedPass == 'wrong' || trimmedPass == 'invalid' || trimmedUser == 'invalid') {
      return const Result.failure(
        UnauthorizedFailure(debugMessage: 'Invalid corporate credentials supplied'),
      );
    }

    // 4. Successful enterprise authentication
    final userDto = UserDto(
      id: 'usr_mr_7821',
      email: trimmedUser.contains('@') ? trimmedUser : '$trimmedUser@novapharma.internal',
      employeeId: trimmedUser.contains('@') ? 'MR-4402' : trimmedUser,
      displayName: 'Alex Morgan',
      role: 'Senior Medical Representative',
      territory: 'Cardio-Metabolic North',
      token: 'jwt_mock_token_sec_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Save tokens and user if keepSignedIn is requested (or standard session)
    if (keepSignedIn) {
      await _localDatasource.saveToken(userDto.token);
    }
    await _localDatasource.saveUser(userDto);

    AppLogger.i('Authentication successful for: ${userDto.displayName}');
    return Result.success(userDto.toDomain());
  }

  @override
  Future<Result<void>> logout() async {
    AppLogger.i('AuthRepository.logout terminating session');
    await _localDatasource.clearToken();
    await _localDatasource.clearUser();
    return const Result.success(null);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final dto = await _localDatasource.getUser();
    return dto?.toDomain();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _localDatasource.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return _localDatasource.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _localDatasource.setOnboardingCompleted();
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return _localDatasource.isBiometricEnabled();
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _localDatasource.setBiometricEnabled(enabled);
  }
}

/// Riverpod Providers for Auth Data Layer
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
  return AuthRepositoryImpl(localDatasource: local);
});
