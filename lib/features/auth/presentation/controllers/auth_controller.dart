import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Sealed representation of Authentication States
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthNeedsOnboarding extends AuthState {
  const AuthNeedsOnboarding();
}

final class AuthUnauthenticated extends AuthState {
  final String? sessionMessage;
  const AuthUnauthenticated({this.sessionMessage});
}

final class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final bool promptBiometrics;

  const AuthAuthenticated({
    required this.user,
    this.promptBiometrics = false,
  });
}

/// Authentication Controller managing app-wide auth lifecycle
class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    // Asynchronously resolve initial state on startup
    Future.microtask(initializeAuth);
    return const AuthInitial();
  }

  /// Evaluates onboarding completion and token existence on startup
  Future<void> initializeAuth() async {
    try {
      final isOnboarded = await _repository.isOnboardingCompleted();
      if (!isOnboarded) {
        AppLogger.i('First launch detected: routing to Onboarding');
        state = const AuthNeedsOnboarding();
        return;
      }

      final isAuthed = await _repository.isAuthenticated();
      if (isAuthed) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          AppLogger.i('Restored active session for: ${user.displayName}');
          state = AuthAuthenticated(user: user, promptBiometrics: false);
          return;
        }
      }

      state = const AuthUnauthenticated();
    } catch (e, st) {
      AppLogger.e('Error during auth initialization', error: e, stackTrace: st);
      state = const AuthUnauthenticated();
    }
  }

  /// Marks onboarding completed and navigates to Login
  Future<void> completeOnboarding() async {
    await _repository.setOnboardingCompleted();
    state = const AuthUnauthenticated();
  }

  /// Authenticates user with corporate credentials
  Future<Failure?> login({
    required String username,
    required String password,
    required bool keepSignedIn,
  }) async {
    state = const AuthAuthenticating();

    final result = await _repository.login(
      username: username,
      password: password,
      keepSignedIn: keepSignedIn,
    );

    return result.when(
      success: (user) {
        state = AuthAuthenticated(
          user: user,
          promptBiometrics: false,
        );
        return null;
      },
      failure: (failure) {
        state = const AuthUnauthenticated();
        return failure;
      },
    );
  }

  /// Updates biometric enrollment preference
  Future<void> setBiometrics(bool enabled) async {
    await _repository.setBiometricEnabled(enabled);
    if (state is AuthAuthenticated) {
      final current = state as AuthAuthenticated;
      state = AuthAuthenticated(user: current.user, promptBiometrics: false);
    }
  }

  /// Dismisses the biometric unlock prompt without enabling
  void dismissBiometricPrompt() {
    if (state is AuthAuthenticated) {
      final current = state as AuthAuthenticated;
      state = AuthAuthenticated(user: current.user, promptBiometrics: false);
    }
  }

  /// Terminates user session
  Future<void> logout({String? message}) async {
    await _repository.logout();
    state = AuthUnauthenticated(sessionMessage: message);
  }

  /// Handles 401 Unauthorized expiration
  void handleSessionExpired() {
    AppLogger.w('Handling centralized session expiration');
    logout(message: 'session_expired');
  }
}

/// App-wide AuthController Provider
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
