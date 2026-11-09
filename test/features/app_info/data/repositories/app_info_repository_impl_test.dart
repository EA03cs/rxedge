import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/features/app_info/data/datasources/app_info_local_datasource.dart';
import 'package:rxedge/features/app_info/data/datasources/app_info_remote_datasource.dart';
import 'package:rxedge/features/app_info/data/models/app_info_dto.dart';
import 'package:rxedge/features/app_info/data/repositories/app_info_repository_impl.dart';

class MockRemoteDatasource extends Mock implements AppInfoRemoteDatasource {}
class MockLocalDatasource extends Mock implements AppInfoLocalDatasource {}

void main() {
  late MockRemoteDatasource mockRemote;
  late MockLocalDatasource mockLocal;
  late AppInfoRepositoryImpl repository;

  final testDto = AppInfoDto(
    appName: 'RxEdge',
    version: '1.0.0',
    buildNumber: '10',
    environment: 'staging',
    apiEndpoint: 'https://api-staging.rxedge.internal',
    minSupportedVersion: '1.0.0',
    maintenanceMode: false,
    serverTimestamp: DateTime(2026, 11, 9, 12, 0),
  );

  setUpAll(() {
    registerFallbackValue(testDto);
  });

  setUp(() {
    mockRemote = MockRemoteDatasource();
    mockLocal = MockLocalDatasource();
    repository = AppInfoRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  group('AppInfoRepositoryImpl - Stale-While-Revalidate Strategy', () {
    test('returns cached AppInfo immediately when cache is fresh', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(true);
      when(() => mockLocal.getCachedAppInfo()).thenAnswer((_) async => testDto);

      final result = await repository.getAppInfo(forceRefresh: false);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.version, '1.0.0');
      verify(() => mockLocal.getCachedAppInfo()).called(1);
      verifyNever(() => mockRemote.getAppInfo());
    });

    test('fetches from remote and updates cache when cache is stale', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getAppInfo()).thenAnswer((_) async => testDto);
      when(() => mockLocal.cacheAppInfo(any())).thenAnswer((_) async {});

      final result = await repository.getAppInfo();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.appName, 'RxEdge');
      verify(() => mockRemote.getAppInfo()).called(1);
      verify(() => mockLocal.cacheAppInfo(testDto)).called(1);
    });

    test('forces remote fetch when forceRefresh is true even if cache is fresh', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(true);
      when(() => mockRemote.getAppInfo()).thenAnswer((_) async => testDto);
      when(() => mockLocal.cacheAppInfo(any())).thenAnswer((_) async {});

      final result = await repository.getAppInfo(forceRefresh: true);

      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.getAppInfo()).called(1);
      verifyNever(() => mockLocal.getCachedAppInfo());
    });

    test('falls back to stale cache if remote fetch throws network exception', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getAppInfo()).thenThrow(const NetworkException('No internet'));
      when(() => mockLocal.getCachedAppInfo()).thenAnswer((_) async => testDto);

      final result = await repository.getAppInfo();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.environment, 'staging');
      verify(() => mockRemote.getAppInfo()).called(1);
      verify(() => mockLocal.getCachedAppInfo()).called(1);
    });

    test('returns FailureResult when remote throws and no cache exists', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(false);
      when(() => mockRemote.getAppInfo()).thenThrow(const ServerException('Service unavailable', statusCode: 503));
      when(() => mockLocal.getCachedAppInfo()).thenAnswer((_) async => null);

      final result = await repository.getAppInfo();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      final failure = result.failureOrNull as ServerFailure;
      expect(failure.statusCode, 503);
    });
  });
}
