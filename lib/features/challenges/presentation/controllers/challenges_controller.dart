import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/challenges_repository_impl.dart';
import '../../domain/entities/challenges_entities.dart';

/// State representation for Challenges tab
class ChallengesDashboardState {
  final MonthlyChallengeEntity monthlyChallenge;
  final List<QuickQuizEntity> quizzes;
  final ObjectionOfTheMonthEntity objection;
  final int selectedTabIndex;

  const ChallengesDashboardState({
    required this.monthlyChallenge,
    required this.quizzes,
    required this.objection,
    this.selectedTabIndex = 0,
  });

  ChallengesDashboardState copyWith({
    MonthlyChallengeEntity? monthlyChallenge,
    List<QuickQuizEntity>? quizzes,
    ObjectionOfTheMonthEntity? objection,
    int? selectedTabIndex,
  }) {
    return ChallengesDashboardState(
      monthlyChallenge: monthlyChallenge ?? this.monthlyChallenge,
      quizzes: quizzes ?? this.quizzes,
      objection: objection ?? this.objection,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

/// Notifier managing Challenges Home State
class ChallengesController extends AutoDisposeAsyncNotifier<ChallengesDashboardState> {
  @override
  Future<ChallengesDashboardState> build() async {
    return _fetchData(forceRefresh: false);
  }

  Future<ChallengesDashboardState> _fetchData({bool forceRefresh = false}) async {
    final repo = ref.watch(challengesRepositoryProvider);

    final monthlyFuture = repo.getMonthlyChallenge(forceRefresh: forceRefresh);
    final quizzesFuture = repo.getQuickQuizzes(forceRefresh: forceRefresh);
    final objectionFuture = repo.getObjectionOfTheMonth(forceRefresh: forceRefresh);

    final results = await Future.wait([monthlyFuture, quizzesFuture, objectionFuture]);

    final monthlyRes = results[0];
    final quizzesRes = results[1];
    final objectionRes = results[2];

    if (monthlyRes.isFailure) {
      throw Exception(monthlyRes.failureOrNull?.debugMessage ?? 'Failed to load challenge');
    }
    if (quizzesRes.isFailure) {
      throw Exception(quizzesRes.failureOrNull?.debugMessage ?? 'Failed to load quizzes');
    }
    if (objectionRes.isFailure) {
      throw Exception(objectionRes.failureOrNull?.debugMessage ?? 'Failed to load objection');
    }

    final currentTab = state.value?.selectedTabIndex ?? 0;

    return ChallengesDashboardState(
      monthlyChallenge: monthlyRes.dataOrNull as MonthlyChallengeEntity,
      quizzes: quizzesRes.dataOrNull as List<QuickQuizEntity>,
      objection: objectionRes.dataOrNull as ObjectionOfTheMonthEntity,
      selectedTabIndex: currentTab,
    );
  }

  void setTabIndex(int index) {
    state = state.whenData((s) => s.copyWith(selectedTabIndex: index));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData(forceRefresh: true));
  }

  Future<void> submitObjectionFeedback(String feedbackType) async {
    final currentState = state.value;
    if (currentState == null) return;

    final repo = ref.read(challengesRepositoryProvider);
    final res = await repo.submitObjectionFeedback(currentState.objection.id, feedbackType);

    res.when(
      success: (updated) {
        state = state.whenData((s) => s.copyWith(objection: updated));
      },
      failure: (_) {},
    );
  }

  Future<void> submitDoctorObjectionResponse(String responseText) async {
    final currentState = state.value;
    if (currentState == null) return;

    final repo = ref.read(challengesRepositoryProvider);
    await repo.submitDoctorObjectionResponse(
      objectionId: currentState.objection.id,
      userResponse: responseText,
    );
  }

  Future<void> onQuizCompleted({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
  }) async {
    final repo = ref.read(challengesRepositoryProvider);
    await repo.submitQuizResult(
      quizId: quizId,
      score: score,
      totalQuestions: totalQuestions,
      timeTakenSeconds: timeTakenSeconds,
    );

    // Refresh state to update quiz completion status
    state = await AsyncValue.guard(() => _fetchData(forceRefresh: false));
  }
}

/// Provider for Challenges Dashboard
final challengesControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChallengesController, ChallengesDashboardState>(
  ChallengesController.new,
);

/// Provider for History of Past Challenges
final pastChallengesHistoryProvider =
    FutureProvider.autoDispose<List<PastChallengeHistoryEntity>>((ref) async {
  final repo = ref.watch(challengesRepositoryProvider);
  final res = await repo.getPastChallengesHistory();
  return res.when(
    success: (list) => list,
    failure: (f) => throw Exception(f.debugMessage ?? 'Failed to load past challenges'),
  );
});

/// Provider for History of Quiz Results
final quizResultsHistoryProvider =
    FutureProvider.autoDispose<List<QuizResultHistoryEntity>>((ref) async {
  final repo = ref.watch(challengesRepositoryProvider);
  final res = await repo.getQuizResultsHistory();
  return res.when(
    success: (list) => list,
    failure: (f) => throw Exception(f.debugMessage ?? 'Failed to load quiz history'),
  );
});
