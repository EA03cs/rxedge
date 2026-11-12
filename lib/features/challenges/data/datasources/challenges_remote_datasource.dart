import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/challenges_dto.dart';

/// Remote Datasource Contract for Challenges & Gamification
abstract class ChallengesRemoteDatasource {
  Future<MonthlyChallengeDto> getMonthlyChallenge();
  Future<List<QuickQuizDto>> getQuickQuizzes();
  Future<QuickQuizDto> getQuizById(String quizId);
  Future<ObjectionOfTheMonthDto> getObjectionOfTheMonth();
  Future<ObjectionOfTheMonthDto> submitObjectionFeedback(String objectionId, String feedbackType);
  Future<void> submitDoctorObjectionResponse(String objectionId, String userResponse);
  Future<QuizResultHistoryDto> submitQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
  });
  Future<QuizSubmissionResultDto> submitQuizAnswers({
    required String quizId,
    required List<Map<String, String>> answers,
  });
  Future<List<PastChallengeHistoryDto>> getPastChallengesHistory();
  Future<List<QuizResultHistoryDto>> getQuizResultsHistory();
}

/// Remote Datasource Implementation backed by Gamification & Competitors APIs
class ChallengesRemoteDatasourceImpl implements ChallengesRemoteDatasource {
  final Dio? dio;
  final bool simulateError;

  ChallengesRemoteDatasourceImpl({
    this.dio,
    this.simulateError = false,
  });

  @override
  Future<MonthlyChallengeDto> getMonthlyChallenge() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve monthly challenge data from server');
    }

    if (dio != null) {
      final responses = await Future.wait([
        dio!.get<dynamic>(ApiEndpoints.monthlyChallenge),
        dio!.get<dynamic>(ApiEndpoints.leaderboard),
      ]);

      final challengeData = ApiResponseParser.unwrapMap(responses[0].data);
      final leaderboardData = ApiResponseParser.unwrapMap(responses[1].data);

      final merged = Map<String, dynamic>.from(challengeData);
      final topUsers = leaderboardData['leaderboard'];
      if (topUsers is List) {
        merged['leaderboard'] = topUsers;
        merged['totalParticipants'] ??= topUsers.length;
      }
      final currentUser = leaderboardData['currentUser'];
      if (currentUser is Map && currentUser['rank'] != null) {
        merged['userRank'] = currentUser['rank'];
      }
      if (merged['id'] == null || (merged['id'] as String).isEmpty) {
        return MonthlyChallengeDto(
          id: 'none',
          title: '',
          deadlineIso: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          rules: const [],
          currentProgress: 0,
          completedMilestones: 0,
          totalMilestones: 0,
          userRank: (merged['userRank'] as num?)?.toInt() ?? 0,
          totalParticipants: (merged['totalParticipants'] as num?)?.toInt() ?? 0,
          rewards: const [],
          leaderboard: (merged['leaderboard'] as List<dynamic>? ?? const [])
              .map((e) => LeaderboardEntryDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return MonthlyChallengeDto.fromJson(merged);
    }

    await Future<void>.delayed(const Duration(milliseconds: 140));

    final deadline = DateTime.now().add(const Duration(days: 4, hours: 14));

    return MonthlyChallengeDto(
      id: 'ch_nov_2026',
      title: 'Cardiovascular Knowledge Blitz: Q4 Master',
      deadlineIso: deadline.toIso8601String(),
      rules: const [
        'Complete all 3 core clinical quick quizzes with >= 80% passing score.',
        'Review the monthly physician objection and formulate your clinical talking points.',
        'Top 3 district performers receive District Spotlight recognition and +500 Pts.',
      ],
      currentProgress: 0.72,
      completedMilestones: 5,
      totalMilestones: 7,
      userRank: 3,
      totalParticipants: 34,
      rewards: const [
        'District Honor Roll Certificate',
        '+500 Professional Gamification Points',
        'Territory Excellence Spotlight Badge',
      ],
      leaderboard: const [
        LeaderboardEntryDto(
          rank: 1,
          repName: 'Sarah Jenkins',
          territory: 'North District - Cardiology',
          points: 1420,
          avatarInitials: 'SJ',
        ),
        LeaderboardEntryDto(
          rank: 2,
          repName: 'Ahmed Mansour',
          territory: 'East District - Internal Med',
          points: 1380,
          avatarInitials: 'AM',
        ),
        LeaderboardEntryDto(
          rank: 3,
          repName: 'Alex Mercer (You)',
          territory: 'Central District - Multispecialty',
          points: 1250,
          isCurrentUser: true,
          avatarInitials: 'AM',
        ),
        LeaderboardEntryDto(
          rank: 4,
          repName: 'Omar Farooq',
          territory: 'South District - Cardiology',
          points: 1190,
          avatarInitials: 'OF',
        ),
        LeaderboardEntryDto(
          rank: 5,
          repName: 'Elena Rostova',
          territory: 'Metro District - Urology',
          points: 1150,
          avatarInitials: 'ER',
        ),
        LeaderboardEntryDto(
          rank: 6,
          repName: 'David Kim',
          territory: 'West District - Primary Care',
          points: 1080,
          avatarInitials: 'DK',
        ),
        LeaderboardEntryDto(
          rank: 7,
          repName: 'Fatima Al-Sayed',
          territory: 'North District - Nephrology',
          points: 1040,
          avatarInitials: 'FA',
        ),
        LeaderboardEntryDto(
          rank: 8,
          repName: 'Marcus Vance',
          territory: 'Central District - Geriatrics',
          points: 990,
          avatarInitials: 'MV',
        ),
        LeaderboardEntryDto(
          rank: 9,
          repName: 'Layla Hassan',
          territory: 'East District - Cardiology',
          points: 960,
          avatarInitials: 'LH',
        ),
        LeaderboardEntryDto(
          rank: 10,
          repName: 'Tariq Ziyad',
          territory: 'South District - Endocrinology',
          points: 920,
          avatarInitials: 'TZ',
        ),
      ],
    );
  }

  @override
  Future<List<QuickQuizDto>> getQuickQuizzes() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve quick quizzes');
    }

    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.quizzes);
      final list = ApiResponseParser.unwrapList(response.data);
      return list.map(QuickQuizDto.fromJson).toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 140));

    return [
      const QuickQuizDto(
        id: 'quiz_crd_01',
        title: 'Cardura XL Peak Efficacy & 24h ABPM Study',
        category: 'Hypertension & BPH',
        durationMinutes: 3,
        rewardPoints: 50,
        isCompleted: true,
        lastScore: 4,
        lastMaxScore: 4,
        questions: [
          QuizQuestionDto(
            id: 'q_crd_01',
            question:
                'What is the key pharmacokinetic advantage of Cardura XL GITS over conventional immediate-release doxazosin?',
            options: [
              'Rapid absorption with high 2-hour peak plasma spikes',
              'Consistent 24-hour plasma plateau with zero peak-to-trough fluctuations',
              'Exclusively renal clearance without hepatic metabolism',
              'Twice-daily divided dosing for maximal vascular compliance',
            ],
            correctOptionIndex: 1,
            explanation:
                'GITS osmotic pump delivery ensures constant zero-order drug release, eliminating hypotensive peaks.',
          ),
          QuizQuestionDto(
            id: 'q_crd_02',
            question:
                'In the PREDICT study, what was the primary 24-hour ambulatory blood pressure reduction achieved by Cardura XL?',
            options: [
              '6.2 mm Hg systolic reduction',
              '10.5 mm Hg systolic reduction',
              '14.2 mm Hg systolic reduction with early morning surge suppression',
              '22.0 mm Hg diastolic reduction exclusively',
            ],
            correctOptionIndex: 2,
            explanation:
                'PREDICT demonstrated 14.2 mm Hg 24h systolic drop and effectively preserved nocturnal dipping.',
          ),
          QuizQuestionDto(
            id: 'q_crd_03',
            question:
                'How should a physician address dose adjustments for an elderly hypertensive patient with Stage 3 CKD starting Cardura XL?',
            options: [
              'Reduce initial dose by 50% to 2mg every other day',
              'No dose adjustment is required due to negligible renal clearance',
              'Avoid Cardura XL completely in moderate renal impairment',
              'Double fluid intake and monitor creatinine twice weekly',
            ],
            correctOptionIndex: 1,
            explanation:
                'Cardura XL undergoes primarily fecal and biliary excretion, requiring zero adjustment in renal impairment.',
          ),
          QuizQuestionDto(
            id: 'q_crd_04',
            question:
                'Which co-morbid symptom improvement is uniquely delivered by Cardura XL in hypertensive men over 55?',
            options: [
              'Reduction in intraocular pressure for glaucoma',
              'Simultaneous reduction in IPSS lower urinary tract BPH symptoms',
              'Elevation in serum HDL-cholesterol by over 30%',
              'Bronchodilation in chronic COPD patients',
            ],
            correctOptionIndex: 1,
            explanation:
                'Cardura XL relaxes bladder neck and prostate smooth muscle, delivering -4.8 point IPSS relief.',
          ),
        ],
      ),
      const QuickQuizDto(
        id: 'quiz_atv_02',
        title: 'AtorvaCare Statin Intolerance & Renal Safety',
        category: 'Lipid Management',
        durationMinutes: 3,
        rewardPoints: 40,
        isCompleted: false,
        questions: [
          QuizQuestionDto(
            id: 'q_atv_01',
            question:
                'What is the recommended LDL-C reduction benchmark for AtorvaCare 20mg in high-risk ASCVD patients?',
            options: [
              '15% to 25% reduction',
              '30% to 40% reduction',
              '45% to 52% reduction from baseline',
              'Greater than 75% reduction',
            ],
            correctOptionIndex: 2,
            explanation:
                'AtorvaCare 20mg provides intensive statin therapy achieving 45-52% mean LDL-C reduction.',
          ),
          QuizQuestionDto(
            id: 'q_atv_02',
            question:
                'How should an MR address physician concerns regarding statin-associated muscle symptoms (SAMS)?',
            options: [
              'Recommend immediately switching to non-statin herbal alternatives',
              'Highlight true myositis incidence is < 0.1% and discuss alternate-day re-challenge protocols',
              'Advise doubling the co-enzyme Q10 dosage without physician oversight',
              'Suggest complete discontinuation of all lipid lowering therapies',
            ],
            correctOptionIndex: 1,
            explanation:
                'Objective trials confirm SAMS incidence is under 0.1%; rechallenge or alternate dosing preserves cardiovascular protection.',
          ),
          QuizQuestionDto(
            id: 'q_atv_03',
            question:
                'In patients with Type 2 Diabetes, what trial confirmed the primary prevention efficacy of AtorvaCare?',
            options: [
              'CARDS Trial (Colleague Atorvastatin Diabetes Study)',
              'ALLHAT Hypertension Registry',
              'HOPE-3 Trial',
              'FOURIER Monoclonal Study',
            ],
            correctOptionIndex: 0,
            explanation:
                'The CARDS trial showed 37% relative risk reduction in major cardiovascular events in diabetic cohorts.',
          ),
        ],
      ),
      const QuickQuizDto(
        id: 'quiz_lps_03',
        title: 'LipiShield Duo Dual-Pathway Absorption Kinetics',
        category: 'Atherosclerosis',
        durationMinutes: 2,
        rewardPoints: 30,
        isCompleted: false,
        questions: [
          QuizQuestionDto(
            id: 'q_lps_01',
            question:
                'What dual complementary pathways are targeted by LipiShield Duo (Atorvastatin + Ezetimibe)?',
            options: [
              'Hepatic cholesterol synthesis inhibition + intestinal cholesterol absorption inhibition',
              'Renal tubular clearance + bile acid sequestration',
              'Beta-blockade + peripheral vasodilation',
              'ACE enzyme inhibition + calcium channel blockade',
            ],
            correctOptionIndex: 0,
            explanation:
                'Dual inhibition addresses both endogenous hepatic synthesis and exogenous intestinal NPC1L1 uptake.',
          ),
          QuizQuestionDto(
            id: 'q_lps_02',
            question:
                'What additional LDL-C lowering is achieved by adding Ezetimibe 10mg to baseline statin monotherapy?',
            options: [
              'Additional 5% reduction',
              'Additional 18% to 24% incremental reduction',
              'Additional 50% reduction regardless of statin dose',
              'Zero additional reduction',
            ],
            correctOptionIndex: 1,
            explanation:
                'Adding Ezetimibe 10mg delivers 18-24% incremental LDL-C lowering without doubling the statin dose.',
          ),
        ],
      ),
    ];
  }

  @override
  Future<QuickQuizDto> getQuizById(String quizId) async {
    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.quizById(quizId));
      final map = ApiResponseParser.unwrapMap(response.data);
      return QuickQuizDto.fromJson(map);
    }

    final list = await getQuickQuizzes();
    final found = list.where((q) => q.id == quizId);
    if (found.isNotEmpty) {
      return found.first;
    }
    throw NotFoundException('Quiz not found: $quizId');
  }

  @override
  Future<ObjectionOfTheMonthDto> getObjectionOfTheMonth() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve objection of the month');
    }

    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.objectionOfMonth);
      final raw = ApiResponseParser.unwrapData(response.data);
      if (raw is Map<String, dynamic> && raw.isNotEmpty) {
        return ObjectionOfTheMonthDto.fromJson(raw);
      }
      if (raw is List && raw.isNotEmpty && raw.first is Map) {
        return ObjectionOfTheMonthDto.fromJson(
          Map<String, dynamic>.from(raw.first as Map),
        );
      }
      return const ObjectionOfTheMonthDto(
        id: '',
        doctorQuote: '',
        doctorName: '',
        doctorSpecialty: '',
        productConcerned: '',
        recommendedResponse: '',
        talkingPoints: [],
        studyReference: '',
        helpfulCount: 0,
        communityResponseCount: 0,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));

    return const ObjectionOfTheMonthDto(
      id: 'obj_nov_2026',
      doctorQuote:
          '“Why should I switch my stable hypertensive patients from Generic Amlodipine to Cardura XL? Amlodipine is inexpensive and familiar.”',
      doctorName: 'Dr. Tarek El-Khouly',
      doctorSpecialty: 'Consultant Interventional Cardiologist, Cairo Heart Institute',
      productConcerned: 'Cardura XL (Doxazosin GITS 4mg / 8mg)',
      recommendedResponse:
          'Acknowledge amlodipine’s baseline efficacy, then pivot to tolerability and multi-morbid precision: Amlodipine induces peripheral ankle edema in up to 15% of patients leading to non-compliance, and provides zero benefit for lower urinary tract symptoms. Cardura XL GITS maintains continuous 24h blood pressure control without peripheral edema, preserves nocturnal dipping, and addresses co-existing BPH in a single morning tablet.',
      talkingPoints: [
        'Acknowledge familiar efficacy, then address the 15% peripheral ankle edema discontinuation rate.',
        'Contrast 24h GITS plateau vs amlodipine trough spikes during the high-risk early morning window.',
        'Highlight dual indication: 60%+ of hypertensive males > 55 have co-existing BPH urinary symptoms.',
        'Single daily pill eliminates redundant polypharmacy and duplicate copay burdens.',
      ],
      studyReference:
          'ASCOT-BPLA Ambulatory Sub-analysis & European Urology Guideline Registry 2025 (p < 0.001)',
      helpfulCount: 48,
      communityResponseCount: 14,
    );
  }

  @override
  Future<ObjectionOfTheMonthDto> submitObjectionFeedback(
    String objectionId,
    String feedbackType,
  ) async {
    final objection = await getObjectionOfTheMonth();
    final newCount = feedbackType == 'helpful' ? objection.helpfulCount + 1 : objection.helpfulCount;
    return ObjectionOfTheMonthDto(
      id: objection.id,
      doctorQuote: objection.doctorQuote,
      doctorName: objection.doctorName,
      doctorSpecialty: objection.doctorSpecialty,
      productConcerned: objection.productConcerned,
      recommendedResponse: objection.recommendedResponse,
      talkingPoints: objection.talkingPoints,
      studyReference: objection.studyReference,
      helpfulCount: newCount,
      userFeedback: feedbackType,
      communityResponseCount: objection.communityResponseCount,
    );
  }

  @override
  Future<void> submitDoctorObjectionResponse(String objectionId, String userResponse) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Persisted or queued
  }

  @override
  Future<QuizResultHistoryDto> submitQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final points = (score * 10) + (score == totalQuestions ? 10 : 0);

    return QuizResultHistoryDto(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      quizId: quizId,
      quizTitle: quizId == 'quiz_crd_01'
          ? 'Cardura XL Peak Efficacy & 24h ABPM Study'
          : 'Clinical Pharmacology Knowledge Check',
      score: score,
      totalQuestions: totalQuestions,
      pointsEarned: points,
      timeTakenSeconds: timeTakenSeconds,
      completedAtIso: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<QuizSubmissionResultDto> submitQuizAnswers({
    required String quizId,
    required List<Map<String, String>> answers,
  }) async {
    if (dio != null) {
      final response = await dio!.post<dynamic>(
        ApiEndpoints.submitQuiz(quizId),
        data: <String, dynamic>{'answers': answers},
      );
      final map = ApiResponseParser.unwrapMap(response.data);
      return QuizSubmissionResultDto.fromJson(map);
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    return QuizSubmissionResultDto(
      attemptId: 'local_${DateTime.now().millisecondsSinceEpoch}',
      score: 100,
      isPassed: true,
      passingScore: 70,
      pointsAwarded: 30,
      answers: const [],
    );
  }

  @override
  Future<List<PastChallengeHistoryDto>> getPastChallengesHistory() async {
    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.pointsHistory);
      final list = ApiResponseParser.unwrapList(
        response.data,
        nestedKeys: const ['items', 'transactions', 'results'],
      );
      return list
          .where((item) => item['type'] == 'challenge_reward')
          .map((item) {
            return PastChallengeHistoryDto(
              id: item['id'] as String? ?? '',
              title: item['description'] as String? ?? '',
              completedAtIso: item['createdAt'] as String? ??
                  DateTime.now().toIso8601String(),
              finalRank: 0,
              totalParticipants: 0,
              pointsEarned: (item['amount'] as num?)?.toInt() ?? 0,
              badgeEarned: null,
            );
          })
          .toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      PastChallengeHistoryDto(
        id: 'ch_oct_2026',
        title: 'October Hypertension Master Sprint',
        completedAtIso: DateTime(2026, 10, 31).toIso8601String(),
        finalRank: 2,
        totalParticipants: 32,
        pointsEarned: 450,
        badgeEarned: 'Silver District Performer',
      ),
      PastChallengeHistoryDto(
        id: 'ch_sep_2026',
        title: 'Q3 Cardiology Clinical Detailing Rally',
        completedAtIso: DateTime(2026, 9, 30).toIso8601String(),
        finalRank: 5,
        totalParticipants: 30,
        pointsEarned: 350,
        badgeEarned: 'Top 5 Territory Leader',
      ),
    ];
  }

  @override
  Future<List<QuizResultHistoryDto>> getQuizResultsHistory() async {
    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.pointsHistory);
      final list = ApiResponseParser.unwrapList(
        response.data,
        nestedKeys: const ['items', 'transactions', 'results'],
      );
      return list
          .where((item) => item['type'] == 'quiz_completion')
          .map((item) {
            return QuizResultHistoryDto(
              id: item['id'] as String? ?? '',
              quizId: item['referenceId'] as String? ?? '',
              quizTitle: item['description'] as String? ?? '',
              score: 0,
              totalQuestions: 0,
              pointsEarned: (item['amount'] as num?)?.toInt() ?? 0,
              timeTakenSeconds: 0,
              completedAtIso: item['createdAt'] as String? ??
                  DateTime.now().toIso8601String(),
            );
          })
          .toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      QuizResultHistoryDto(
        id: 'hist_01',
        quizId: 'quiz_crd_01',
        quizTitle: 'Cardura XL Peak Efficacy & 24h ABPM Study',
        score: 4,
        totalQuestions: 4,
        pointsEarned: 50,
        timeTakenSeconds: 94,
        completedAtIso: DateTime(2026, 11, 7, 14, 20).toIso8601String(),
      ),
      QuizResultHistoryDto(
        id: 'hist_02',
        quizId: 'quiz_atv_02',
        quizTitle: 'AtorvaCare Statin Intolerance & Renal Safety',
        score: 3,
        totalQuestions: 3,
        pointsEarned: 40,
        timeTakenSeconds: 78,
        completedAtIso: DateTime(2026, 11, 5, 11, 15).toIso8601String(),
      ),
    ];
  }
}
