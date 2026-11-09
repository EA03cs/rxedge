import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/core/error/exceptions.dart';
import 'package:rxedge/features/feedback/data/datasources/feedback_local_datasource.dart';
import 'package:rxedge/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:rxedge/features/feedback/data/models/feedback_dto.dart';
import 'package:rxedge/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:rxedge/features/feedback/domain/entities/feedback_entities.dart';

class MockFeedbackRemoteDatasource extends Mock implements FeedbackRemoteDatasource {}

class MockFeedbackLocalDatasource extends Mock implements FeedbackLocalDatasource {}

void main() {
  late MockFeedbackRemoteDatasource mockRemote;
  late MockFeedbackLocalDatasource mockLocal;
  late FeedbackRepositoryImpl repository;

  final sampleDto = FeedbackItemDto(
    id: 'fb_1',
    typeString: 'doctorObjection',
    title: 'Cardura XL Dosing Concern',
    submittedAtIso: DateTime(2026, 11, 9, 10, 0).toIso8601String(),
    statusString: 'answered',
    product: 'Cardura XL',
    objection: 'Doctor Vance concerned with orthostatic hypotension',
    marketingReply: 'Clinical slide updated in upcoming deck',
    repliedBy: 'Dr. Kareem',
    repliedAtIso: DateTime(2026, 11, 9, 12, 0).toIso8601String(),
  );

  const sampleDraftDto = FeedbackDraftDto(
    typeString: 'doctorObjection',
    product: 'Cardura XL',
    objection: 'Doctor concerned about timing',
  );

  setUpAll(() {
    registerFallbackValue(sampleDto);
    registerFallbackValue(sampleDraftDto);
  });

  setUp(() {
    mockRemote = MockFeedbackRemoteDatasource();
    mockLocal = MockFeedbackLocalDatasource();
    repository = FeedbackRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  group('FeedbackRepositoryImpl - getSubmissions', () {
    test('returns cached submissions immediately when cache is fresh', () async {
      when(() => mockLocal.isCacheFresh('feedback_submissions')).thenReturn(true);
      when(() => mockLocal.getCachedSubmissions()).thenAnswer((_) async => [sampleDto]);

      final result = await repository.getSubmissions(forceRefresh: false);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (list) {
          expect(list.length, 1);
          expect(list.first.id, 'fb_1');
          expect(list.first.type, FeedbackType.doctorObjection);
        },
        failure: (_) => fail('Expected success'),
      );
      verify(() => mockLocal.getCachedSubmissions()).called(1);
      verifyZeroInteractions(mockRemote);
    });

    test('fetches from remote and updates cache when cache is stale', () async {
      when(() => mockLocal.isCacheFresh('feedback_submissions')).thenReturn(false);
      when(() => mockRemote.getSubmissions()).thenAnswer((_) async => [sampleDto]);
      when(() => mockLocal.cacheSubmissions(any())).thenAnswer((_) async {});

      final result = await repository.getSubmissions(forceRefresh: false);

      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.getSubmissions()).called(1);
      verify(() => mockLocal.cacheSubmissions([sampleDto])).called(1);
    });

    test('falls back to stale cache if remote fetch throws network exception', () async {
      when(() => mockLocal.isCacheFresh('feedback_submissions')).thenReturn(false);
      when(() => mockRemote.getSubmissions()).thenThrow(const NetworkException('No connection'));
      when(() => mockLocal.getCachedSubmissions()).thenAnswer((_) async => [sampleDto]);

      final result = await repository.getSubmissions(forceRefresh: false);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (list) => expect(list.first.id, 'fb_1'),
        failure: (_) => fail('Expected cached fallback'),
      );
    });
  });

  group('FeedbackRepositoryImpl - submitFeedback', () {
    test('submits remotely, clears draft, and caches in memory on success', () async {
      final item = sampleDto.toDomain();
      when(() => mockRemote.submitFeedback(any())).thenAnswer((_) async => sampleDto);
      when(() => mockLocal.clearDraft('doctorObjection')).thenAnswer((_) async {});

      final result = await repository.submitFeedback(item);

      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.submitFeedback(any())).called(1);
      verify(() => mockLocal.clearDraft('doctorObjection')).called(1);
    });

    test('queues offline, sets status to pending, and clears draft on remote failure', () async {
      final item = sampleDto.toDomain();
      when(() => mockRemote.submitFeedback(any())).thenThrow(const NetworkException('Offline'));
      when(() => mockLocal.queueFeedbackSubmission(any())).thenAnswer((_) async {});
      when(() => mockLocal.clearDraft('doctorObjection')).thenAnswer((_) async {});

      final result = await repository.submitFeedback(item);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (pendingItem) {
          expect(pendingItem.status, FeedbackStatus.pending);
          expect(pendingItem.id, startsWith('pending_'));
        },
        failure: (_) => fail('Expected offline queued item'),
      );
      verify(() => mockLocal.queueFeedbackSubmission(any())).called(1);
      verify(() => mockLocal.clearDraft('doctorObjection')).called(1);
    });
  });

  group('FeedbackRepositoryImpl - Drafts', () {
    test('gets and saves draft correctly', () async {
      when(() => mockLocal.getDraft('doctorObjection')).thenAnswer((_) async => sampleDraftDto);
      when(() => mockLocal.saveDraft(any())).thenAnswer((_) async {});

      final getResult = await repository.getDraft(FeedbackType.doctorObjection);
      expect(getResult.isSuccess, isTrue);
      getResult.when(
        success: (draft) {
          expect(draft?.product, 'Cardura XL');
          expect(draft?.objection, 'Doctor concerned about timing');
        },
        failure: (_) => fail('Expected success'),
      );

      final saveResult = await repository.saveDraft(
        const FeedbackDraftEntity(
          type: FeedbackType.doctorObjection,
          product: 'Cardura XL',
        ),
      );
      expect(saveResult.isSuccess, isTrue);
      verify(() => mockLocal.saveDraft(any())).called(1);
    });
  });
}
