import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/features/library/data/datasources/library_local_datasource.dart';
import 'package:rxedge/features/library/data/datasources/library_remote_datasource.dart';
import 'package:rxedge/features/library/data/models/material_item_dto.dart';
import 'package:rxedge/features/library/data/repositories/library_repository_impl.dart';

class MockLibraryRemoteDatasource extends Mock implements LibraryRemoteDatasource {}
class MockLibraryLocalDatasource extends Mock implements LibraryLocalDatasource {}

void main() {
  late MockLibraryRemoteDatasource mockRemote;
  late MockLibraryLocalDatasource mockLocal;
  late LibraryRepositoryImpl repository;

  final testDtos = [
    const MaterialItemDto(
      id: 'mat_01',
      title: 'Cardura XL Official Prescribing Monograph',
      productName: 'Cardura XL',
      category: 'brochure',
      fileType: 'pdf',
      fileSizeBytes: 3400000,
      updatedAt: '2026-11-04T10:00:00Z',
      badge: 'updated',
      isFavorite: false,
      isDownloaded: false,
      viewCount: 140,
      pageCount: 8,
      description: 'Comprehensive clinical pharmacokinetics and GITS dosing.',
    ),
    const MaterialItemDto(
      id: 'mat_02',
      title: 'AtorvaCare SAMS Management Clinical Presentation',
      productName: 'AtorvaCare 20mg',
      category: 'edetail',
      fileType: 'edetail',
      fileSizeBytes: 12000000,
      updatedAt: '2026-11-07T14:30:00Z',
      badge: 'new',
      isFavorite: true,
      isDownloaded: true,
      viewCount: 88,
      pageCount: 6,
      description: 'Detailing deck on statin adherence.',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(testDtos);
  });

  setUp(() {
    mockRemote = MockLibraryRemoteDatasource();
    mockLocal = MockLibraryLocalDatasource();
    repository = LibraryRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );

    when(() => mockLocal.getFavorites()).thenAnswer((_) async => {'mat_02'});
    when(() => mockLocal.getDownloadedIds()).thenAnswer((_) async => {'mat_02'});
    when(() => mockLocal.isCacheFresh()).thenReturn(false);
  });

  group('LibraryRepositoryImpl Tests', () {
    test('fetches remote materials and merges with local favorites/downloads', () async {
      when(() => mockRemote.getMaterials()).thenAnswer((_) async => testDtos);
      when(() => mockLocal.cacheMaterials(any())).thenAnswer((_) async {});

      final result = await repository.getMaterials();

      expect(result.isSuccess, isTrue);
      final items = result.dataOrNull!;
      expect(items.length, 2);
      expect(items[0].productName, 'Cardura XL');
      expect(items[0].isFavorite, isFalse);
      expect(items[1].isFavorite, isTrue);
      expect(items[1].isDownloaded, isTrue);
      verify(() => mockRemote.getMaterials()).called(1);
      verify(() => mockLocal.cacheMaterials(testDtos)).called(1);
    });

    test('returns cached materials when cache is fresh', () async {
      when(() => mockLocal.isCacheFresh()).thenReturn(true);
      when(() => mockLocal.getCachedMaterials()).thenAnswer((_) async => testDtos);

      final result = await repository.getMaterials(forceRefresh: false);

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.getCachedMaterials()).called(1);
      verifyNever(() => mockRemote.getMaterials());
    });

    test('toggleFavorite updates local storage and memory', () async {
      when(() => mockRemote.getMaterials()).thenAnswer((_) async => testDtos);
      when(() => mockLocal.cacheMaterials(any())).thenAnswer((_) async {});
      when(() => mockLocal.saveFavorites(any())).thenAnswer((_) async {});

      // Initial fetch to populate memory
      await repository.getMaterials();

      // Toggle favorite on mat_01 (was false -> should become true)
      final favResult = await repository.toggleFavorite('mat_01');

      expect(favResult.isSuccess, isTrue);
      expect(favResult.dataOrNull?.isFavorite, isTrue);
      verify(() => mockLocal.saveFavorites(any())).called(1);
    });

    test('markDownloaded and removeDownload update local storage and memory', () async {
      when(() => mockRemote.getMaterials()).thenAnswer((_) async => testDtos);
      when(() => mockLocal.cacheMaterials(any())).thenAnswer((_) async {});
      when(() => mockLocal.saveDownloadedIds(any())).thenAnswer((_) async {});

      await repository.getMaterials();

      // Mark downloaded
      final dlResult = await repository.markDownloaded('mat_01');
      expect(dlResult.isSuccess, isTrue);

      final item = (await repository.getMaterialById('mat_01')).dataOrNull!;
      expect(item.isDownloaded, isTrue);

      // Remove download
      final removeResult = await repository.removeDownload('mat_01');
      expect(removeResult.isSuccess, isTrue);

      final itemAfterRemove = (await repository.getMaterialById('mat_01')).dataOrNull!;
      expect(itemAfterRemove.isDownloaded, isFalse);
    });

    test('returns Failure when remote throws and no cache exists', () async {
      when(() => mockRemote.getMaterials()).thenThrow(const ServerException('500 Error'));
      when(() => mockLocal.getCachedMaterials()).thenAnswer((_) async => null);

      final result = await repository.getMaterials();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
    });
  });
}
