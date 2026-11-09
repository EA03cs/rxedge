import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:rxedge/features/auth/data/models/user_dto.dart';
import 'package:rxedge/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthLocalDatasource extends Mock implements AuthLocalDatasource {}

void main() {
  late MockAuthLocalDatasource mockLocal;
  late AuthRepositoryImpl repository;

  const testUserDto = UserDto(
    id: 'usr_1',
    email: 'rep@pharma.com',
    employeeId: 'MR-1049',
    displayName: 'Alex Morgan',
    role: 'Medical Representative',
    territory: 'Cardio North',
    token: 'jwt_mock_token_123',
  );

  setUpAll(() {
    registerFallbackValue(testUserDto);
  });

  setUp(() {
    mockLocal = MockAuthLocalDatasource();
    repository = AuthRepositoryImpl(localDatasource: mockLocal);
  });

  group('AuthRepositoryImpl Tests', () {
    test('successful login saves token when keepSignedIn is true and returns UserEntity', () async {
      when(() => mockLocal.saveToken(any())).thenAnswer((_) async {});
      when(() => mockLocal.saveUser(any())).thenAnswer((_) async {});

      final result = await repository.login(
        username: 'rep@pharma.com',
        password: 'ValidPassword123',
        keepSignedIn: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.displayName, 'Alex Morgan');
      verify(() => mockLocal.saveToken(any())).called(1);
      verify(() => mockLocal.saveUser(any())).called(1);
    });

    test('login with empty fields returns ValidationFailure', () async {
      final result = await repository.login(
        username: '',
        password: '',
        keepSignedIn: true,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('login with "wrong" password returns UnauthorizedFailure', () async {
      final result = await repository.login(
        username: 'rep@pharma.com',
        password: 'wrong',
        keepSignedIn: true,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });

    test('login with "offline" username returns NetworkFailure', () async {
      final result = await repository.login(
        username: 'offline_user',
        password: 'Password123',
        keepSignedIn: true,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('logout clears token and cached user', () async {
      when(() => mockLocal.clearToken()).thenAnswer((_) async {});
      when(() => mockLocal.clearUser()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.clearToken()).called(1);
      verify(() => mockLocal.clearUser()).called(1);
    });

    test('onboarding check and completion delegates to local datasource', () async {
      when(() => mockLocal.isOnboardingCompleted()).thenAnswer((_) async => false);
      when(() => mockLocal.setOnboardingCompleted()).thenAnswer((_) async {});

      expect(await repository.isOnboardingCompleted(), isFalse);

      await repository.setOnboardingCompleted();
      verify(() => mockLocal.setOnboardingCompleted()).called(1);
    });
  });
}
