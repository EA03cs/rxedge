import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/core/storage/local_cache_service.dart';
import 'package:rxedge/core/storage/offline_queue_service.dart';
import 'package:rxedge/core/storage/storage_initializer.dart';
import 'package:rxedge/features/auth/data/models/user_dto.dart';
import 'package:rxedge/features/challenges/data/models/challenges_dto.dart';
import 'package:rxedge/features/feedback/data/datasources/feedback_local_datasource.dart';
import 'package:rxedge/features/feedback/data/models/feedback_dto.dart';
import 'package:rxedge/features/home/data/models/home_dashboard_dto.dart';
import 'package:rxedge/features/learn/data/models/learning_dto.dart';
import 'package:rxedge/features/library/data/models/material_item_dto.dart';
import 'package:rxedge/features/notifications/data/models/notification_dto.dart';

void main() {
  group('Backend DTO Parsing Contracts', () {
    test('UserDto parses backend nested territory, employeeCode, and tokens', () {
      final dto = UserDto.fromJson(<String, dynamic>{
        'id': 'u-1',
        'email': 'rep@rxedge.com',
        'employeeCode': 'EMP-009',
        'fullName': 'أحمد علي',
        'role': 'medical_rep',
        'territory': <String, dynamic>{'id': 't-1', 'name': 'القاهرة الكبرى'},
        'accessToken': 'jwt-access',
        'refreshToken': 'jwt-refresh',
        'totalPoints': 480,
        'currentStreak': 6,
      });

      final domain = dto.toDomain();
      expect(domain.employeeId, 'EMP-009');
      expect(domain.displayName, 'أحمد علي');
      expect(domain.territory, 'القاهرة الكبرى');
      expect(domain.token, 'jwt-access');
      expect(dto.refreshToken, 'jwt-refresh');
    });

    test('HomeDashboardDto parses camelCase backend dashboard payload', () {
      final dto = HomeDashboardDto.fromJson(<String, dynamic>{
        'continueLearningLesson': <String, dynamic>{
          'id': 'les-1',
          'title': 'تقنية تيرشيلد لاستعادة الطبقة الدمعية',
          'productName': 'Rohto Dry Aid',
        },
        'lessonProgress': <String, dynamic>{
          'completedLessons': 3,
          'totalLessons': 5,
        },
        'recommendedProduct': <String, dynamic>{
          'id': 'prod-1',
          'name': 'Rohto Dry Aid',
          'therapeuticAreaName': 'طب وجراحة العيون',
          'description': 'استعادة ترطيب العين حتى 12 ساعة',
        },
        'monthlyChallenge': <String, dynamic>{
          'id': 'ch-1',
          'title': 'تحدي الشهر',
          'endDate': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
          'targetPoints': 500,
          'userProgress': <String, dynamic>{
            'currentPoints': 250,
            'percentage': 50,
          },
          'totalParticipants': 18,
          'earnedPoints': 250,
        },
        'currentChallengeRank': 3,
        'objectionOfTheMonth': <String, dynamic>{
          'id': 'obj-1',
          'doctorQuote': 'لماذا التحويل إلى Rohto Dry Aid؟',
          'recommendedResponse': 'تركيبة فريدة تحاكي الطبقات الثلاث لدموع العين.',
          'productName': 'Rohto Dry Aid',
        },
        'recentClinicalMaterials': <dynamic>[
          <String, dynamic>{
            'id': 'mat-1',
            'title': 'دليل الجرعات',
            'productName': 'Rohto Dry Aid',
            'fileType': 'clinical_pdf',
            'version': 2,
          },
        ],
        'userPoints': 1250,
        'currentStreak': 7,
        'completedQuizzes': 4,
      });

      final entity = dto.toDomain();
      expect(entity.continueLesson?.productName, 'Rohto Dry Aid');
      expect(entity.continueLesson?.completedModules, 3);
      expect(entity.continueLesson?.totalModules, 5);
      expect(entity.recommendedProduct?.therapeuticArea, 'طب وجراحة العيون');
      expect(entity.challenge.currentRank, 3);
      expect(entity.objection.doctorQuote, 'لماذا التحويل إلى Rohto Dry Aid؟');
      expect(entity.recentMaterials.single.badgeType.name, 'updated');
      expect(entity.stats.points, 1250);
    });

    test('ProductLearningDto parses lessons content into sections and competitors', () {
      final dto = ProductLearningDto.fromJson(<String, dynamic>{
        'id': 'prod-uuid-1',
        'name': 'AtorvaCare',
        'therapeuticArea': 'الدهون والكوليسترول',
        'keyMessage': 'خفض فعال للكوليسترول الضار',
        'lessons': <dynamic>[
          <String, dynamic>{
            'id': 'les-uuid-1',
            'title': 'أساسيات العلاج',
            'estimatedMinutes': 6,
            'summary': 'ملخص سريع للدرس',
            'content': 'الفقرة الأولى\n\nالفقرة الثانية',
            'isCompleted': true,
          },
        ],
        'competitors': <dynamic>[
          <String, dynamic>{
            'id': 'comp-1',
            'competitorName': 'Generic Statin',
            'theirClaim': 'سعر أقل',
            'howToRespond': 'أدلة سريرية أقوى وثبات جرعة',
          },
        ],
      });

      final domain = dto.toDomain();
      expect(domain.lessons.single.sections.isNotEmpty, isTrue);
      expect(domain.lessons.single.isCompleted, isTrue);
      expect(domain.competitors.single.howToRespond, 'أدلة سريرية أقوى وثبات جرعة');
    });

    test('MaterialItemDto maps backend types e_detailing & clinical_pdf', () {
      final pdfDto = MaterialItemDto.fromJson(<String, dynamic>{
        'id': 'm1',
        'title': 'Monograph PDF',
        'type': 'clinical_pdf',
        'fileSize': 204800,
        'version': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'fileUrl': '/uploads/materials/doc.pdf',
      });
      final deckDto = MaterialItemDto.fromJson(<String, dynamic>{
        'id': 'm2',
        'title': 'E-Detailing Deck',
        'type': 'e_detailing',
        'slides': <dynamic>[
          <String, dynamic>{'slideOrder': 1, 'title': 'Slide 1', 'imageUrl': '/uploads/s1.png'},
        ],
      });

      expect(pdfDto.fileType, 'pdf');
      expect(pdfDto.badge, 'new');
      expect(pdfDto.fileUrl, '/uploads/materials/doc.pdf');
      expect(deckDto.fileType, 'edetail');
      expect(deckDto.slides.single.slideNumber, 1);
      expect(deckDto.slides.single.imageUrl, '/uploads/s1.png');
    });

    test('QuickQuizDto & QuizSubmissionResultDto handle server-side quiz flow', () {
      final quiz = QuickQuizDto.fromJson(<String, dynamic>{
        'id': 'q-1',
        'title': 'اختبار القلب',
        'timeLimitSeconds': 180,
        'pointsReward': 50,
        'questionsCount': 1,
        'questions': <dynamic>[
          <String, dynamic>{
            'id': 'qq-1',
            'questionText': 'ما الجرعة الابتدائية؟',
            'options': <dynamic>[
              <String, dynamic>{'id': 'opt-a', 'text': '4 مجم'},
              <String, dynamic>{'id': 'opt-b', 'text': '16 مجم'},
            ],
          },
        ],
        'startDate': '2026-11-01T00:00:00Z',
        'endDate': '2026-11-30T23:59:59Z',
        'completionWindowDays': 3,
      });

      final submission = QuizSubmissionResultDto.fromJson(<String, dynamic>{
        'attemptId': 'att-1',
        'score': 100,
        'isPassed': true,
        'passingScore': 70,
        'pointsAwarded': 50,
        'answers': <dynamic>[
          <String, dynamic>{
            'questionId': 'qq-1',
            'selectedOptionId': 'opt-a',
            'isCorrect': true,
            'correctOptionId': 'opt-a',
            'correctOptionText': '4 مجم',
            'explanation': '4 مجم مرة يومياً هي الجرعة المبدئية.',
          },
        ],
      });

      expect(quiz.durationMinutes, 3);
      expect(quiz.questions.single.optionIds, ['opt-a', 'opt-b']);
      expect(quiz.startDate, DateTime.utc(2026, 11, 1, 0, 0, 0));
      expect(quiz.endDate, DateTime.utc(2026, 11, 30, 23, 59, 59));
      expect(quiz.completionWindowDays, 3);
      final entity = quiz.toDomain();
      expect(entity.completionWindowDays, 3);
      expect(submission.isPassed, isTrue);
      expect(submission.pointsAwarded, 50);
      expect(submission.answers.single.correctOptionText, '4 مجم');
    });

    test('FeedbackItemDto.toBackendPayload validates UUID productId and HTTP attachment', () {
      const dto = FeedbackItemDto(
        id: 'local_1',
        clientSubmissionId: '11111111-1111-4111-8111-111111111111',
        productId: 'not-a-uuid',
        typeString: 'doctorObjection',
        title: 'Cardura XL',
        submittedAtIso: '2026-11-12T10:00:00Z',
        objection: 'الدواء مكلف مقارنة بالبدائل',
        doctorSpecialty: 'قلب وأوعية دموية',
        howResponded: 'شرحنا ثبات 24 ساعة',
        photoUrl: 'assets/mock/ignored.jpg',
      );

      final payload = dto.toBackendPayload();
      expect(payload['clientSubmissionId'], '11111111-1111-4111-8111-111111111111');
      expect(payload['category'], 'doctor_objection');
      expect(payload.containsKey('productId'), isFalse);
      expect(payload.containsKey('attachmentUrl'), isFalse);
      expect(payload['details'], 'الدواء مكلف مقارنة بالبدائل');
      expect(payload['representativeResponse'], 'شرحنا ثبات 24 ساعة');
    });

    test('NotificationDto normalizes /feedback/detail and feedback_detail routes', () {
      final fromSlash = NotificationDto.fromJson(<String, dynamic>{
        'id': 'notif-1',
        'type': 'feedback_reply',
        'title': 'رد جديد',
        'body': 'تم الرد على ملاحظتك',
        'targetScreen': '/feedback/detail',
        'targetId': 'fb-123',
      });
      final fromSnake = NotificationDto.fromJson(<String, dynamic>{
        'id': 'notif-2',
        'type': 'feedback_reply',
        'title': 'رد جديد',
        'body': 'تم الرد',
        'targetScreen': 'feedback_detail',
        'targetId': 'fb-456',
      });
      final fromGamification = NotificationDto.fromJson(<String, dynamic>{
        'id': 'notif-3',
        'type': 'new_challenge',
        'title': 'تحدي جديد',
        'body': 'انطلق تحدي الإتقان الميداني',
        'targetScreen': 'gamification',
      });
      final fromMedia = NotificationDto.fromJson(<String, dynamic>{
        'id': 'notif-4',
        'type': 'new_material',
        'title': 'مادة جديدة',
        'body': 'شرائح جديدة',
        'targetScreen': 'media',
      });
      final fromHome = NotificationDto.fromJson(<String, dynamic>{
        'id': 'notif-5',
        'type': 'quiz_reminder',
        'title': 'تنبيه',
        'body': 'مرحبا بك',
        'targetScreen': 'HOME',
      });

      expect(fromSlash.targetRoute, '/feedback/detail');
      expect(fromSlash.targetId, 'fb-123');
      expect(fromSnake.targetRoute, '/feedback/detail');
      expect(fromSnake.targetId, 'fb-456');
      expect(fromGamification.targetRoute, '/challenges');
      expect(fromMedia.targetRoute, '/library');
      expect(fromHome.targetRoute, isNull);
    });

    test('FeedbackLocalDatasourceImpl queues localAttachmentPath for offline photo replay', () async {
      final queue = OfflineQueueService();
      final cache = LocalCacheService();
      final local = FeedbackLocalDatasourceImpl(
        cacheService: cache,
        queueService: queue,
      );

      await local.queueFeedbackSubmission(
        const FeedbackItemDto(
          id: 'pending_1',
          clientSubmissionId: '11111111-1111-4111-8111-111111111111',
          typeString: 'competitorClaim',
          title: 'Competitor Claim',
          submittedAtIso: '2026-11-12T10:00:00Z',
          competitorName: 'PharmaX',
          claim: 'Unverified flyer',
          photoUrl: '/data/user/0/app/pending_photo.jpg',
          voiceNoteUrl: '/data/user/0/app/pending_voice.m4a',
        ),
      );

      expect(queue.pendingItems, hasLength(1));
      final queuedPayload = queue.pendingItems.single.payload;
      expect(queuedPayload.containsKey('attachmentUrl'), isFalse);
      expect(queuedPayload.containsKey('voiceNoteUrl'), isFalse);
      expect(queuedPayload['localAttachmentPath'], '/data/user/0/app/pending_photo.jpg');
      expect(queuedPayload['localVoiceNotePath'], '/data/user/0/app/pending_voice.m4a');
    });

    test('FeedbackItemDto.toBackendPayload includes HTTP attachmentUrl and voiceNoteUrl', () {
      const dto = FeedbackItemDto(
        id: 'fb_2',
        clientSubmissionId: '11111111-1111-4111-8111-111111111111',
        typeString: 'fieldFeedback',
        title: 'Field Suggestion',
        submittedAtIso: '2026-11-12T10:00:00Z',
        details: 'Need printed pocket cards',
        photoUrl: 'http://rxedge.agro-plus.net/uploads/feedback/photo.jpg',
        voiceNoteUrl: 'http://rxedge.agro-plus.net/uploads/feedback/voice.m4a',
      );

      final payload = dto.toBackendPayload();
      expect(payload['attachmentUrl'], 'http://rxedge.agro-plus.net/uploads/feedback/photo.jpg');
      expect(payload['voiceNoteUrl'], 'http://rxedge.agro-plus.net/uploads/feedback/voice.m4a');
    });

    test('StorageInitializer reads fallback ThemeMode when box is not opened', () {
      expect(StorageInitializer.readInitialThemeMode(), ThemeMode.light);
    });

    test('HomeDashboardDto & Challenges DTOs prefer Challenge Marks & Personal Dashboard fields', () {
      final home = HomeDashboardDto.fromJson(<String, dynamic>{
        'creditsEarned': 640,
        'challengeMarks': 640,
        'userPoints': 100, // legacy lower value ignored in favor of challengeMarks
        'monthlySubmissions': 5,
        'currentStreak': 9,
        'completedQuizzes': 6,
        'individualProgress': <String, dynamic>{
          'completedLessons': 4,
          'totalLessons': 6,
        },
        'quarterlyBadges': <dynamic>[
          <String, dynamic>{
            'badgeId': 'b-q4',
            'title': 'Dry Eye Specialist',
            'quarter': 4,
            'year': 2026,
          },
        ],
        'monthlyChallenge': <String, dynamic>{
          'id': 'ch-m',
          'title': 'Q4 Sprint',
          'userProgress': <String, dynamic>{
            'currentChallengeMarks': 180,
            'targetChallengeMarks': 250,
          },
          'totalParticipants': 12,
        },
        'objectionOfTheMonth': <String, dynamic>{
          'id': 'obj-1',
          'doctorQuote': 'Why Tearshield?',
          'recommendedResponse': '3-layer relief.',
        },
      }).toDomain();

      expect(home.stats.challengeMarks, 640);
      expect(home.stats.monthlySubmissions, 5);
      expect(home.stats.completedLessons, 4);
      expect(home.stats.totalLessons, 6);
      expect(home.stats.quarterlyBadges.single.title, 'Dry Eye Specialist');
      expect(home.stats.quarterlyBadges.single.quarter, 4);
      expect(home.challenge.progress, closeTo(0.72, 0.01));

      final quiz = QuickQuizDto.fromJson(<String, dynamic>{
        'id': 'q-cm',
        'title': 'Rohto Marks Quiz',
        'challengeMarksReward': 80,
        'pointsReward': 30,
        'isCompleted': true,
        'lastScore': 3,
        'lastMaxScore': 4,
      }).toDomain();
      expect(quiz.rewardPoints, 80);
      expect(quiz.isCompleted, isTrue);
      expect(quiz.lastScore, 3);
      expect(quiz.lastMaxScore, 4);

      final submission = QuizSubmissionResultDto.fromJson(<String, dynamic>{
        'attemptId': 'att-cm',
        'score': 100,
        'isPassed': true,
        'challengeMarksAwarded': 80,
        'pointsAwarded': 20,
        'answers': const <dynamic>[],
      }).toDomain();
      expect(submission.pointsAwarded, 80);
    });

    test('HomeDashboardDto does not fabricate fake progress or streak when backend omits data', () {
      final home = HomeDashboardDto.fromJson(<String, dynamic>{
        'challengeMarks': 0,
        'continueLearningLesson': null,
        'recommendedProduct': null,
        'monthlyChallenge': null,
        'objectionOfTheMonth': null,
        'recentClinicalMaterials': const <dynamic>[],
      }).toDomain();

      expect(home.continueLesson, isNull);
      expect(home.recommendedProduct, isNull);
      expect(home.challenge.id, isEmpty);
      expect(home.challenge.title, isEmpty);
      expect(home.challenge.progress, 0.0);
      expect(home.challenge.daysLeft, 0);
      expect(home.challenge.currentRank, 0);
      expect(home.stats.streakDays, 0);
      expect(home.stats.points, 0);
      expect(home.recentMaterials, isEmpty);

      final partialLesson = ContinueLearningDto.fromJson(<String, dynamic>{
        'id': 'les-1',
        'title': 'Dry Eye Basics',
        'productName': 'Rohto Dry Aid',
      }).toDomain();
      expect(partialLesson.progress, 0.0);
      expect(partialLesson.completedModules, 0);
      expect(partialLesson.totalModules, 0);
    });
  });
}
