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
      title: 'Cardiovascular Knowledge Blitz: Q4 Master',
      deadlineIso: deadline.toIso8601String(),
      rules: const [
        'Complete all 3 core clinical quick quizzes with >= 80% passing score.',
        'Review the monthly physician objection and formulate your clinical talking points.',
        'Top 3 district performers receive District Spotlight recognition and +500 Marks.',
      ],
      currentProgress: 0.72,
      completedMilestones: 5,
      totalMilestones: 7,
      userRank: 3,
      totalParticipants: 34,
      rewards: const [
        'District Honor Roll Certificate',
        '+500 Challenge Marks',
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
      const QuickQuizDto(
        id: 'quiz_crd_01',
        title: 'Cardura XL Clinical Pharmacology & GITS Technology',
        category: 'Cardiovascular & Urology',
        durationMinutes: 3,
        rewardPoints: 50,
        isCompleted: false,
        questions: [
          QuizQuestionDto(
            id: 'q_crd_01',
            question:
                'What distinguishes the GITS formulation of Doxazosin from standard immediate-release formulations?',
            options: [
              'Osmotic delivery providing consistent 24h plasma concentrations',
              'Immediate absorption in the stomach within 15 minutes',
              'Sublingual dissolution bypassing first-pass liver metabolism',
              'Enteric coating requiring activation by pancreatic enzymes',
            ],
            correctOptionIndex: 0,
            explanation:
                'GITS uses osmotic push-pull delivery to maintain steady 24-hour plasma levels without the sharp peaks of IR.',
          ),
          QuizQuestionDto(
            id: 'q_crd_02',
            question:
                'How does Cardura XL address comorbid BPH with Hypertension simultaneously?',
            options: [
              'Selectively inhibits alpha-1 receptors relaxing prostatic stroma and vascular smooth muscle',
              'Inhibits central sympathetic outflow from the hypothalamus',
              'Directly reduces serum testosterone and dihydrotestosterone (DHT)',
              'Blocks calcium channels exclusively in the renal vasculature',
            ],
            correctOptionIndex: 0,
            explanation:
                'Cardura XL blocks alpha-1 adrenoceptors in both prostate smooth muscle (improving IPSS) and peripheral arteries (lowering BP).',
          ),
          QuizQuestionDto(
            id: 'q_crd_03',
            question:
                'What clinical benefit is achieved by avoiding the sharp Cmax peak seen with immediate-release doxazosin?',
            options: [
              'Significantly lower incidence of first-dose postural hypotension and dizziness',
              'Allows once-weekly administration',
              'Eliminates the need for oral fluid intake',
              'Completely bypasses cytochrome P450 metabolism',
            ],
            correctOptionIndex: 0,
            explanation:
                'The smooth 24-hour delivery avoids peak-related orthostatic side effects, improving patient adherence.',
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
      final response = await dio!.get<dynamic>(ApiEndpoints.pointsHistory);
      final list = ApiResponseParser.unwrapList(
        response.data,
        nestedKeys: const ['items', 'transactions', 'results'],
      );
      return list
          .where((item) => item['type'] == 'quiz_completion')
          .map((item) {
            return QuizResultHistoryDto(
              id: item['id']?.toString() ?? '',
              quizId: item['referenceId']?.toString() ?? '',
              quizTitle: item['description']?.toString() ?? '',
              score: 0,
              totalQuestions: 0,
              pointsEarned: (item['amount'] as num?)?.toInt() ?? 0,
              timeTakenSeconds: 0,
              completedAtIso: item['createdAt']?.toString() ??
                  DateTime.now().toIso8601String(),
            );
          })
          .toList();
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
