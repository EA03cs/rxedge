import 'dart:convert';
import '../../../../core/services/logger_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/offline_queue_service.dart';
import '../models/feedback_dto.dart';

/// Local Datasource Contract for Live Marketing Feedback
abstract class FeedbackLocalDatasource {
  Future<List<FeedbackItemDto>?> getCachedSubmissions();
  Future<void> cacheSubmissions(List<FeedbackItemDto> submissions);

  Future<FeedbackDraftDto?> getDraft(String typeString);
  Future<void> saveDraft(FeedbackDraftDto draft);
  Future<void> clearDraft(String typeString);

  Future<void> queueFeedbackSubmission(FeedbackItemDto item);
  bool isCacheFresh(String key);
}

/// Local Datasource Implementation using LocalCacheService & OfflineQueueService
class FeedbackLocalDatasourceImpl implements FeedbackLocalDatasource {
  final LocalCacheService _cacheService;
  final OfflineQueueService _queueService;

  static const String _submissionsKey = 'feedback_submissions';
  static const String _draftPrefix = 'feedback_draft_';

  FeedbackLocalDatasourceImpl({
    required LocalCacheService cacheService,
    required OfflineQueueService queueService,
  })  : _cacheService = cacheService,
        _queueService = queueService;

  @override
  bool isCacheFresh(String key) {
    return _cacheService.isFresh(key);
  }

  @override
  Future<List<FeedbackItemDto>?> getCachedSubmissions() async {
    final raw = _cacheService.get<String>(_submissionsKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => FeedbackItemDto.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.w('Failed parsing cached feedback submissions: $e');
      return null;
    }
  }

  @override
  Future<void> cacheSubmissions(List<FeedbackItemDto> submissions) async {
    final list = submissions.map((e) => e.toJson()).toList();
    _cacheService.put<String>(_submissionsKey, jsonEncode(list));
  }

  @override
  Future<FeedbackDraftDto?> getDraft(String typeString) async {
    final key = '$_draftPrefix$typeString';
    final raw = _cacheService.get<String>(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return FeedbackDraftDto.fromJson(map);
    } catch (e) {
      AppLogger.w('Failed parsing cached feedback draft for $typeString: $e');
      return null;
    }
  }

  @override
  Future<void> saveDraft(FeedbackDraftDto draft) async {
    final key = '$_draftPrefix${draft.typeString}';
    _cacheService.put<String>(key, jsonEncode(draft.toJson()));
  }

  @override
  Future<void> clearDraft(String typeString) async {
    final key = '$_draftPrefix$typeString';
    _cacheService.remove(key);
  }

  @override
  Future<void> queueFeedbackSubmission(FeedbackItemDto item) async {
    _queueService.enqueue(
      OfflineQueueItem(
        id: 'fb_queue_${DateTime.now().millisecondsSinceEpoch}',
        endpoint: '/api/v1/marketing/feedback',
        httpMethod: 'POST',
        payload: item.toJson(),
        createdAt: DateTime.now(),
      ),
    );
    AppLogger.d('Queued feedback submission offline: ${item.title}');
  }
}
