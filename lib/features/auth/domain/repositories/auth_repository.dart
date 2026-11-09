import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// Abstract Authentication Repository Contract
abstract class AuthRepository {
  /// Authenticates with corporate credentials
  Future<Result<UserEntity>> login({
    required String username,
    required String password,
    required bool keepSignedIn,
  });

  /// Terminates active session and clears tokens
  Future<Result<void>> logout();

  /// Retrieves current authenticated user from local storage
  Future<UserEntity?> getCurrentUser();

  /// Whether valid auth token is currently stored
  Future<bool> isAuthenticated();

  /// Whether onboarding has been completed
  Future<bool> isOnboardingCompleted();

  /// Flags onboarding as completed
  Future<void> setOnboardingCompleted();

  /// Whether biometric unlock is enabled
  Future<bool> isBiometricEnabled();

  /// Updates biometric unlock preference
  Future<void> setBiometricEnabled(bool enabled);
}
