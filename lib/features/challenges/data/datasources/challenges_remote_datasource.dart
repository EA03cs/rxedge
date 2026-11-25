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
  Future<QuizSubmissionResultDto> getQuizAttemptReview(String quizId);
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
      if (merged['id'] == null || merged['id'].toString().isEmpty) {
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
      title: 'Ophthalmology Clinical Mastery: Q4 Challenge',
      deadlineIso: deadline.toIso8601String(),
      rules: const [
        'Complete all monthly Eye-Know quick quizzes with >= 70% passing score.',
        'One attempt is permitted per participant per quiz (no retakes).',
        'Top quarterly performers earn official Excellence Badges based on dashboard performance.',
      ],
      currentProgress: 0.72,
      completedMilestones: 5,
      totalMilestones: 7,
      userRank: 3,
      totalParticipants: 34,
      rewards: const [
        'District Honor Roll Certificate',
        '+500 Challenge Marks',
        'Quarterly Ophthalmology Excellence Badge',
      ],
      leaderboard: const [
        LeaderboardEntryDto(
          rank: 1,
          repName: 'Sarah Jenkins',
          territory: 'North District - Ophthalmology',
          points: 1420,
          avatarInitials: 'SJ',
        ),
        LeaderboardEntryDto(
          rank: 2,
          repName: 'Ahmed Mansour',
          territory: 'East District - Ophthalmology',
          points: 1380,
          avatarInitials: 'AM',
        ),
        LeaderboardEntryDto(
          rank: 3,
          repName: 'Ahmed Mostafa (You)',
          territory: 'Cairo North & Heliopolis District',
          points: 1250,
          isCurrentUser: true,
          avatarInitials: 'AM',
        ),
        LeaderboardEntryDto(
          rank: 4,
          repName: 'Omar Farooq',
          territory: 'South District - Ophthalmology',
          points: 1190,
          avatarInitials: 'OF',
        ),
        LeaderboardEntryDto(
          rank: 5,
          repName: 'Elena Rostova',
          territory: 'Metro District - Ophthalmology',
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
          territory: 'North District - Ophthalmology',
          points: 1040,
          avatarInitials: 'FA',
        ),
        LeaderboardEntryDto(
          rank: 8,
          repName: 'Marcus Vance',
          territory: 'Central District - Ophthalmology',
          points: 990,
          avatarInitials: 'MV',
        ),
        LeaderboardEntryDto(
          rank: 9,
          repName: 'Layla Hassan',
          territory: 'East District - Ophthalmology',
          points: 960,
          avatarInitials: 'LH',
        ),
        LeaderboardEntryDto(
          rank: 10,
          repName: 'Tariq Ziyad',
          territory: 'South District - Ophthalmology',
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
        id: 'quiz_rda_01',
        title: 'Rohto Dry Aid Advanced Tearshield Clinical Quiz',
        category: 'Ophthalmology (Dry Eye)',
        durationMinutes: 3,
        rewardPoints: 50,
        isCompleted: true,
        lastScore: 4,
        lastMaxScore: 4,
        questions: [
          QuizQuestionDto(
            id: 'q_rda_01',
            question:
                'What is the primary mechanism of Tearshield Technology in Rohto Dry Aid?',
            options: [
              'Temporary saline flush of ocular surface',
              'Multi-layer restoration stabilizing the lipid, aqueous, and mucin layers',
              'Induction of temporary corneal numbness',
              'Pupil constriction for enhanced depth of field',
            ],
            correctOptionIndex: 1,
            explanation:
                'Tearshield Technology mimics natural tear composition across all 3 layers, locking in moisture for up to 12 hours.',
          ),
          QuizQuestionDto(
            id: 'q_rda_02',
            question:
                'What distinguishes Rohto Dry Aid from ordinary lubricating eye drops?',
            options: [
              'High viscosity requiring nighttime-only application',
              'Non-blurring micro-emulsion formulation providing instant clear vision',
              'Contains benzalkonium chloride preservatives',
              'Causes heavy tear film disruption',
            ],
            correctOptionIndex: 1,
            explanation:
                'Rohto micro-emulsion technology hydrates without causing visual blur or sticky residues.',
          ),
          QuizQuestionDto(
            id: 'q_rda_03',
            question:
                'Which dry eye etiology benefits most from Rohto Dry Aid lipid stabilization?',
            options: [
              'Aqueous-deficient dry eye only',
              'Evaporative dry eye associated with Meibomian Gland Dysfunction (MGD)',
              'Infectious bacterial conjunctivitis',
              'Acute angle-closure attacks',
            ],
            correctOptionIndex: 1,
            explanation:
                'Up to 86% of dry eye cases involve MGD and evaporative tear loss, which Rohto lipid restoration directly addresses.',
          ),
          QuizQuestionDto(
            id: 'q_rda_04',
            question:
                'How does Rohto Dry Aid deliver soothing relief for prolonged screen users?',
            options: [
              'Suppresses blink reflexes',
              'Continuous moisture retention shielding cornea from digital evaporation',
              'Induces sleepiness',
              'Dilates conjunctival vasculature',
            ],
            correctOptionIndex: 1,
            explanation:
                'Tearshield creates a non-evaporating barrier that protects corneas during extended screen exposure.',
          ),
        ],
      ),
      const QuickQuizDto(
        id: 'quiz_cool_02',
        title: 'Rohto Cool Contact Lens Comfort & Hydration',
        category: 'Ophthalmology (CLADE)',
        durationMinutes: 3,
        rewardPoints: 40,
        isCompleted: false,
        questions: [
          QuizQuestionDto(
            id: 'q_cool_01',
            question:
                'How are Rohto Cool & Rohto Aqua formulated specifically for contact lens wearers?',
            options: [
              'Require waiting 45 minutes before inserting lenses',
              'Lubricate, help reduce temporary corneal hypoxia discomfort, and inhibit lens deposits',
              'Contain high-viscosity oil ointments',
              'Only approved for overnight orthokeratology lenses',
            ],
            correctOptionIndex: 1,
            explanation:
                'Rohto Cool and Rohto Aqua address CLADE by moisturizing, helping reduce temporary corneal hypoxia discomfort, and helping inhibit deposit accumulation on contact lenses.',
          ),
          QuizQuestionDto(
            id: 'q_cool_02',
            question: 'What gentle preservative is used in Rohto Dry Aid, Rohto Cool, and Rohto Aqua?',
            options: [
              'Benzalkonium Chloride (BAK)',
              'Polyhexamethylene Biguanide (PHMB)',
              'Thimerosal',
              'Sodium Perborate',
            ],
            correctOptionIndex: 1,
            explanation:
                'Rohto eye drops contain Polyhexamethylene Biguanide (PHMB), a gentle and safe preservative.',
          ),
          QuizQuestionDto(
            id: 'q_cool_03',
            question: 'What is the bottle size of Rohto Cool and Rohto Aqua?',
            options: [
              '13 mL bottle',
              '5 mL bottle',
              '25 mL bottle',
              'Single-use 0.4 mL vials',
            ],
            correctOptionIndex: 0,
            explanation:
                'Both Rohto Cool and Rohto Aqua come in a convenient 13 mL bottle, whereas Rohto Dry Aid comes in a 10 mL bottle.',
          ),
        ],
      ),
      const QuickQuizDto(
        id: 'quiz_aqua_03',
        title: 'Rohto Aqua Gentle Soothing & Post-Surgical Care',
        category: 'Ophthalmology (Dry Eye)',
        durationMinutes: 2,
        rewardPoints: 30,
        isCompleted: false,
        questions: [
          QuizQuestionDto(
            id: 'q_aqua_01',
            question:
                'Between Rohto Aqua and Rohto Cool, which option is recommended after LASIK or eye surgery?',
            options: [
              'Rohto Aqua, as it gently lubricates and soothes the eyes',
              'Rohto Cool for maximum cooling sensation',
              'Neither option can ever be used as a lubricant',
              'Hypertonic saline ointment only',
            ],
            correctOptionIndex: 0,
            explanation:
                'Rohto Aqua is recommended for gentle lubrication and soothing of the eyes.',
          ),
          QuizQuestionDto(
            id: 'q_aqua_02',
            question: 'How do Rohto Dry Aid and Hyaluronic Acid (HA) drops differ?',
            options: [
              'HA restores the lipid layer only',
              'Rohto Dry Aid replenishes both lipid and muco-aqueous layers, while HA benefits the aqueous layer only',
              'Both work identically on the mucin layer only',
              'Rohto Dry Aid has no effect on tear evaporation',
            ],
            correctOptionIndex: 1,
            explanation:
                'Rohto Dry Aid provides replenishment to both the lipid layer and the muco-aqueous layer, whereas HA benefits the aqueous layer only.',
          ),
        ],
      ),
      const QuickQuizDto(
        id: 'quiz_rda_mgd_04',
        title: 'Rohto Dry Aid Formulation & MGD Shelf-Life Facts',
        category: 'Ophthalmology (MGD)',
        durationMinutes: 3,
        rewardPoints: 50,
        isCompleted: false,
        questions: [
          QuizQuestionDto(
            id: 'q_mgd_01',
            question: 'Why does Rohto Dry Aid include Menthol in its formulation?',
            options: [
              'Solely as an artificial fragrance',
              'Refreshes and stimulates meibomian glands to enhance the lipid layer in MGD',
              'Acts as an antibiotic against keratitis',
              'Constricts pupil diameter',
            ],
            correctOptionIndex: 1,
            explanation:
                'Menthol gives a refreshing sensation and contributes to enhancing the lipid layer by stimulating meibomian glands, suiting MGD patients.',
          ),
          QuizQuestionDto(
            id: 'q_mgd_02',
            question: 'How long can Rohto Dry Aid be used after its very first opening?',
            options: [
              '3 months after first opening',
              '14 days only',
              '12 months',
              '24 hours single day use',
            ],
            correctOptionIndex: 0,
            explanation:
                'Rohto Dry Aid remains usable for up to 3 months after its very first opening.',
          ),
          QuizQuestionDto(
            id: 'q_mgd_03',
            question: 'How long before wearing contact lenses should Rohto Dry Aid be instilled?',
            options: [
              '15 to 20 minutes before wearing contact lenses',
              'Directly over soft contact lenses',
              'At least 6 hours prior',
              'Only after sleeping overnight',
            ],
            correctOptionIndex: 0,
            explanation:
                'Remove contact lenses, apply Rohto Dry Aid, and wait 15 to 20 minutes before wearing contact lenses.',
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

  static const ObjectionOfTheMonthDto defaultRohtoObjection = ObjectionOfTheMonthDto(
    id: 'obj_nov_2026',
    doctorQuote:
        '“Why switch patients to Rohto Dry Aid from basic artificial tears? Saline drops are cheap and familiar.”',
    doctorName: 'Dr. Tarek El-Khouly',
    doctorSpecialty: 'Consultant Ophthalmologist, Eye & Laser Center',
    productConcerned: 'Rohto Dry Aid (Tearshield Technology™)',
    recommendedResponse:
        'Acknowledge standard lubricating drops, then pivot to retention and multi-layer restoration: Basic saline drops wash out within 15-20 minutes requiring frequent re-application and causing blurry vision. Rohto Dry Aid with Tearshield Technology restores all 3 natural tear film layers (lipid, aqueous, mucin) keeping the corneal surface lubricated for up to 12 hours with zero vision blur.',
    talkingPoints: [
      'Highlight Tearshield Technology stabilizing the natural lipid layer preventing tear evaporation.',
      'Contrast 12h long-lasting relief vs 15-minute washout of ordinary saline drops.',
      'Emphasize non-blurring formulation enabling immediate return to screen work and driving.',
      'Clinically proven relief for both evaporative dry eye and Meibomian Gland Dysfunction (MGD).',
    ],
    studyReference:
        'Journal of Ocular Pharmacology & Therapeutics Multi-Center Dry Eye Trial (p < 0.001)',
    helpfulCount: 48,
    communityResponseCount: 14,
  );

  @override
  Future<ObjectionOfTheMonthDto> getObjectionOfTheMonth() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve objection of the month');
    }

    if (dio != null) {
      try {
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
      } catch (e) {
        // Fallback to default objection if endpoint returns 404 or fails
        return defaultRohtoObjection;
      }
      return defaultRohtoObjection;
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    return defaultRohtoObjection;
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
      quizTitle: quizId == 'quiz_rda_01'
          ? 'Rohto Dry Aid Advanced Tearshield Clinical Quiz'
          : 'Ophthalmology Clinical Knowledge Check',
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
  Future<QuizSubmissionResultDto> getQuizAttemptReview(String quizId) async {
    if (dio != null) {
      final response = await dio!.get<dynamic>(
        ApiEndpoints.quizAttemptReview(quizId),
      );
      final map = ApiResponseParser.unwrapMap(response.data);
      return QuizSubmissionResultDto.fromJson(map);
    }

    final quiz = await getQuizById(quizId);
    final evals = quiz.questions.map((q) {
      final correctIdx = q.correctOptionIndex.clamp(0, q.options.length - 1);
      final correctText =
          q.options.isNotEmpty ? q.options[correctIdx] : '';
      return QuizAnswerEvaluationDto(
        questionId: q.id,
        questionText: q.question,
        selectedOptionId:
            q.optionIds.isNotEmpty && correctIdx < q.optionIds.length
                ? q.optionIds[correctIdx]
                : null,
        selectedOptionText: correctText,
        isCorrect: true,
        explanation: q.explanation,
        correctOptionId:
            q.optionIds.isNotEmpty && correctIdx < q.optionIds.length
                ? q.optionIds[correctIdx]
                : null,
        correctOptionText: correctText,
      );
    }).toList();

    return QuizSubmissionResultDto(
      attemptId: 'review_$quizId',
      score: 100,
      isPassed: true,
      passingScore: 70,
      pointsAwarded: quiz.rewardPoints,
      answers: evals,
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
              id: item['id']?.toString() ?? '',
              title: item['description']?.toString() ?? '',
              completedAtIso: item['createdAt']?.toString() ??
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
        title: 'October Ophthalmology Master Sprint',
        completedAtIso: DateTime(2026, 10, 31).toIso8601String(),
        finalRank: 2,
        totalParticipants: 32,
        pointsEarned: 450,
        badgeEarned: 'Silver District Performer',
      ),
      PastChallengeHistoryDto(
        id: 'ch_sep_2026',
        title: 'Q3 Dry Eye Clinical Detailing Rally',
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
      final response = await dio!.get<dynamic>(ApiEndpoints.myQuizAttempts);
      final list = ApiResponseParser.unwrapList(
        response.data,
        nestedKeys: const ['items', 'attempts', 'results'],
      );
      return list.map((item) => QuizResultHistoryDto.fromJson(item)).toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      QuizResultHistoryDto(
        id: 'hist_01',
        quizId: 'quiz_rda_01',
        quizTitle: 'Rohto Dry Aid Advanced Tearshield Clinical Quiz',
        score: 4,
        totalQuestions: 4,
        pointsEarned: 50,
        timeTakenSeconds: 94,
        completedAtIso: DateTime(2026, 11, 7, 14, 20).toIso8601String(),
      ),
      QuizResultHistoryDto(
        id: 'hist_02',
        quizId: 'quiz_cool_02',
        quizTitle: 'Rohto Cool Contact Lens Comfort & Hydration',
        score: 3,
        totalQuestions: 3,
        pointsEarned: 40,
        timeTakenSeconds: 78,
        completedAtIso: DateTime(2026, 11, 5, 11, 15).toIso8601String(),
      ),
    ];
  }
}
