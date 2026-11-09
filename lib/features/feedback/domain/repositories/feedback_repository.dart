library;

import '../../../../core/utils/result.dart';
import '../entities/feedback_entities.dart';

/// Abstract Contract for Live Marketing Feedback Repository
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."
abstract class FeedbackRepository {
  Future<Result<List<FeedbackItemEntity>>> getSubmissions({bool forceRefresh = false});
  Future<Result<FeedbackItemEntity>> getSubmissionById(String id);
  Future<Result<FeedbackItemEntity>> submitFeedback(FeedbackItemEntity item);
  Future<Result<FeedbackDraftEntity?>> getDraft(FeedbackType type);
  Future<Result<void>> saveDraft(FeedbackDraftEntity draft);
  Future<Result<void>> clearDraft(FeedbackType type);
}
