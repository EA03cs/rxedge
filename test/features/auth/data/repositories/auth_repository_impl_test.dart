import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:rxedge/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rxedge/features/auth/data/models/user_dto.dart';
import 'package:rxedge/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthLocalDatasource extends Mock implements AuthLocalDatasource {}

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  late MockAuthLocalDatasource mockLocal;
  late MockAuthRemoteDatasource mockRemote;
  late AuthRepositoryImpl repository;

  const testUserDto = UserDto(
    id: 'usr_1',
    email: 'rep@pharma.com',
    employeeId: 'MR-1049',
    displayName: 'Alex Morgan',
    role: 'Medical Representative',
    territory: 'Cardio North',
    token: 'jwt_mock_token_123',
    refreshToken: 'refresh_token_123',
  );

  setUpAll(() {
    registerFallbackValue(testUserDto);
  });

  setUp(() {
    mockLocal = MockAuthLocalDatasource();
    mockRemote = MockAuthRemoteDatasource();
    repository = AuthRepositoryImpl(
      localDatasource: mockLocal,
      remoteDatasource: mockRemote,
    );
  });

  group('AuthRepositoryImpl Tests', () {
    test(
      'successful login saves tokens and user when keepSignedIn is true and returns UserEntity',
      () async {
        when(
          () => mockRemote.login(
            email: 'rep@pharma.com',
            password: 'ValidPassword123',
          ),
        ).thenAnswer((_) async => testUserDto);
        when(() => mockLocal.saveToken(any())).thenAnswer((_) async {});
        when(() => mockLocal.saveRefreshToken(any())).thenAnswer((_) async {});
        when(() => mockLocal.saveUser(any())).thenAnswer((_) async {});

        final result = await repository.login(
          username: 'rep@pharma.com',
          password: 'ValidPassword123',
          keepSignedIn: true,
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.displayName, 'Alex Morgan');
        verify(() => mockLocal.saveToken('jwt_mock_token_123')).called(1);
        verify(
          () => mockLocal.saveRefreshToken('refresh_token_123'),
        ).called(1);
        verify(() => mockLocal.saveUser(testUserDto)).called(1);
      },
    );

    test('login with empty fields returns ValidationFailure', () async {
      final result = await repository.login(
        username: '',
        password: '',
        keepSignedIn: true,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('login returning UnauthorizedException maps to UnauthorizedFailure', () async {
      when(
        () => mockRemote.login(
          email: 'rep@pharma.com',
          password: 'wrong',
        ),
      ).thenThrow(const UnauthorizedException('Invalid credentials'));

      final result = await repository.login(
        username: 'rep@pharma.com',
        password: 'wrong',
        keepSignedIn: true,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });

    test('login returning NetworkException maps to NetworkFailure', () async {
      when(
        () => mockRemote.login(
          email: 'offline_user',
          password: 'Password123',
        ),
      ).thenThrow(const NetworkException());

      final result = await repository.login(
        username: 'offline_user',
        password: 'Password123',
        keepSignedIn: true,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('logout calls remote logout when refresh token exists and clears local storage', () async {
      when(() => mockLocal.getRefreshToken())
          .thenAnswer((_) async => 'refresh_token_123');
      when(() => mockRemote.logout(refreshToken: 'refresh_token_123'))
          .thenAnswer((_) async {});
      when(() => mockLocal.clearToken()).thenAnswer((_) async {});
      when(() => mockLocal.clearRefreshToken()).thenAnswer((_) async {});
      when(() => mockLocal.clearUser()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.logout(refreshToken: 'refresh_token_123'))
          .called(1);
      verify(() => mockLocal.clearToken()).called(1);
      verify(() => mockLocal.clearRefreshToken()).called(1);
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
