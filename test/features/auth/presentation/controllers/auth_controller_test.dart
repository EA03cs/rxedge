import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rxedge/features/auth/domain/entities/user_entity.dart';
import 'package:rxedge/features/auth/domain/repositories/auth_repository.dart';
import 'package:rxedge/features/auth/presentation/controllers/auth_controller.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  const testUser = UserEntity(
    id: 'usr_1',
    email: 'rep@pharma.com',
    employeeId: 'MR-1049',
    displayName: 'Alex Morgan',
    role: 'Medical Representative',
    territory: 'Cardio North',
    token: 'jwt_mock_token_123',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('AuthController Tests', () {
    test('routes to AuthNeedsOnboarding on first launch when onboarding is false', () async {
      when(() => mockRepository.isOnboardingCompleted()).thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Trigger initialization
      await container.read(authControllerProvider.notifier).initializeAuth();

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthNeedsOnboarding>());
    });

    test('restores session to AuthAuthenticated when token exists', () async {
      when(() => mockRepository.isOnboardingCompleted()).thenAnswer((_) async => true);
      when(() => mockRepository.isAuthenticated()).thenAnswer((_) async => true);
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => testUser);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).initializeAuth();

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthAuthenticated>());
      final authed = state as AuthAuthenticated;
      expect(authed.user.displayName, 'Alex Morgan');
    });

    test('successful login prompts biometrics on first enrollment', () async {
      when(() => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
            keepSignedIn: any(named: 'keepSignedIn'),
          )).thenAnswer((_) async => const Result.success(testUser));
      when(() => mockRepository.isBiometricEnabled()).thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final failure = await container.read(authControllerProvider.notifier).login(
            username: 'rep@pharma.com',
            password: 'Password123',
            keepSignedIn: true,
          );

      expect(failure, isNull);
      final state = container.read(authControllerProvider);
      expect(state, isA<AuthAuthenticated>());
      final authed = state as AuthAuthenticated;
      expect(authed.promptBiometrics, isTrue);
    });

    test('failed login returns Failure and remains AuthUnauthenticated', () async {
      const failureObj = UnauthorizedFailure(debugMessage: 'Wrong credentials');
      when(() => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
            keepSignedIn: any(named: 'keepSignedIn'),
          )).thenAnswer((_) async => const Result.failure(failureObj));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final failure = await container.read(authControllerProvider.notifier).login(
            username: 'rep@pharma.com',
            password: 'wrong',
            keepSignedIn: true,
          );

      expect(failure, failureObj);
      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
    });

    test('handleSessionExpired sets state to AuthUnauthenticated with clear message', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async => const Result.success(null));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(authControllerProvider.notifier).handleSessionExpired();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthUnauthenticated>());
      final unauthed = state as AuthUnauthenticated;
      expect(unauthed.sessionMessage, 'session_expired');
    });
  });
}
