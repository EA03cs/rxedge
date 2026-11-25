import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/core/settings/app_settings_model.dart';
import 'package:rxedge/features/feedback/data/models/feedback_dto.dart';
import 'package:rxedge/features/feedback/domain/entities/feedback_entities.dart';
import 'package:rxedge/features/learn/data/models/learning_dto.dart';
import 'package:rxedge/features/library/data/models/material_item_dto.dart';
import 'package:rxedge/features/library/domain/entities/material_item_entity.dart';

void main() {
  group('Module 1: Product Navigator DTO Tests', () {
    test('successfully parses Rohto Dry Aid product payload with FAQs, PackShots, Studies & Target Patient', () {
      final rohtoPayload = <String, dynamic>{
        'id': 'prod-dry-aid-001',
        'brandCode': 'ROHTO-DRY-AID',
        'name': 'Rohto Dry Aid',
        'therapeuticArea': 'Ophthalmology - Dry Eye Relief',
        'isRecommended': true,
        'boxImageUrl': 'https://drive.google.com/file/d/1VNDLsNCR0yirkhYAkpm1GKwwPWlbLkXv/view?usp=sharing',
        'packShots': [
          {
            'id': 'ps-1',
            'imageUrl': 'https://drive.google.com/file/d/1VNDLsNCR0yirkhYAkpm1GKwwPWlbLkXv/view?usp=sharing',
            'orderIndex': 1,
          },
          {
            'id': 'ps-2',
            'imageUrl': 'https://drive.google.com/file/d/1s8dehOKVLUGe0hm__a5A6_GbNA6sHzIw/view?usp=sharing',
            'orderIndex': 2,
          },
        ],
        'supportingStudies': [
          {
            'id': 'ss-1',
            'title': 'E-Detailed Slides & Clinical Efficacy Studies',
            'fileUrl': 'https://drive.google.com/file/d/1jaenvaltpOhA0x82DN2OHV39twZn9ms-/view?usp=drive_link',
            'studyType': 'e_detailed_slides',
            'orderIndex': 1,
          },
        ],
        'faqs': [
          {
            'id': 'faq-1',
            'question': 'What does TEARSHIELD TECHNOLOGY™ mean?',
            'answer': 'Rohto Dry Aid’s TEARSHIELD TECHNOLOGY™ restores and lubricates the natural tear film.',
            'orderIndex': 1,
          },
        ],
        'productOverview': 'Unlike most lubricating eye drops that only work on one layer...',
        'positioning': {
          'key_positioning': 'Rohto Dry Aid with Tearshield Technology formulation hydrates...',
          'key_messaging': [
            'Provides fast-acting dry eye relief',
            'Convenient 10 mLs bottle'
          ],
          'key_message': 'Restores and lubricates the natural tear film for long-lasting relief.',
          'target_doctors': 'Ophthalmologists, Optometrists',
          'target_patient': 'Patients with severe Dryness including Meibomian Gland Dysfunction (MGD)',
          'key_benefits': 'Unique with Menthol and Sesame oil; Relieves symptoms up to 12 hours.',
          'dosage_highlights': 'Convenient 10 ml container.',
          'proof_points': 'Superior relief from visual tasking discomfort.',
        },
        'competitors': <Map<String, dynamic>>[],
        'lessons': <Map<String, dynamic>>[],
      };

      final dto = ProductLearningDto.fromJson(rohtoPayload);

      expect(dto.id, 'prod-dry-aid-001');
      expect(dto.name, 'Rohto Dry Aid');
      expect(dto.productOverview, contains('Unlike most lubricating'));
      expect(dto.positioning.keyPositioning, contains('Rohto Dry Aid with Tearshield'));
      expect(dto.positioning.keyMessaging.length, 2);
      expect(dto.packShots.length, 2);
      expect(dto.packShots[0].imageUrl, contains('1VNDLsNCR0yirkhYAkpm1GKwwPWlbLkXv'));
      expect(dto.supportingStudies.length, 1);
      expect(dto.supportingStudies[0].studyType, 'e_detailed_slides');
      expect(dto.faqs.length, 1);
      expect(dto.faqs[0].question, 'What does TEARSHIELD TECHNOLOGY™ mean?');
      expect(dto.positioning.targetPatient, 'Patients with severe Dryness including Meibomian Gland Dysfunction (MGD)');

      final domain = dto.toDomain();
      expect(domain.productOverview, contains('Unlike most lubricating'));
      expect(domain.positioning.effectiveKeyPositioning, contains('Rohto Dry Aid with Tearshield'));
      expect(domain.positioning.keyMessaging.length, 2);
      expect(domain.packShots.length, 2);
      expect(domain.supportingStudies.length, 1);
      expect(domain.faqs.length, 1);
      expect(domain.positioning.targetPatient, contains('Meibomian Gland Dysfunction'));
    });

    test('handles null/missing productOverview and keyMessaging gracefully', () {
      final minimalPayload = <String, dynamic>{
        'id': 'prod-002',
        'name': 'Rohto Cool',
        'therapeuticArea': 'Ophthalmology',
        'isRecommended': false,
        'positioning': {
          'key_message': 'Cooling relief',
        },
      };

      final dto = ProductLearningDto.fromJson(minimalPayload);
      expect(dto.productOverview, isNull);
      expect(dto.positioning.keyMessaging, isEmpty);
      expect(dto.positioning.effectiveKeyPositioning, 'Cooling relief');

      final domain = dto.toDomain();
      expect(domain.productOverview, isNull);
      expect(domain.positioning.keyMessaging, isEmpty);
      expect(domain.positioning.effectiveKeyPositioning, 'Cooling relief');
    });
  });

  group('Centralized App Settings Tests', () {
    test('successfully parses AppSettings payload', () {
      final json = <String, dynamic>{
        'translationsEnabled': false,
        'defaultLanguage': 'en',
        'supportedLanguages': ['en'],
        'updatedAt': '2026-11-18T13:21:22.131Z',
      };

      final settings = AppSettings.fromJson(json);
      expect(settings.translationsEnabled, false);
      expect(settings.defaultLanguage, 'en');
      expect(settings.supportedLanguages, ['en']);
      expect(settings.updatedAt, isNotNull);
    });
  });

  group('Module 2: Marketing Hub DTO Tests', () {
    test('parses material with quarterly metadata and brochure category', () {
      final json = <String, dynamic>{
        'id': 'mat-001',
        'title': 'Rohto Dry Aid Clinical Brochure',
        'productName': 'Rohto Dry Aid',
        'type': 'brochure',
        'file_url': 'https://drive.google.com/file/d/1jaenvaltpOhA0x82DN2OHV39twZn9ms-/view?usp=drive_link',
        'quarter': 4,
        'year': 2026,
      };

      final dto = MaterialItemDto.fromJson(json);
      expect(dto.quarter, 4);
      expect(dto.year, 2026);
      expect(dto.category, 'brochure');

      final domain = dto.toDomain();
      expect(domain.category, MaterialCategory.brochure);
      expect(domain.quarter, 4);
      expect(domain.year, 2026);
    });
  });

  group('Module 4: Rep Voice DTO Tests', () {
    test('normalizes competitors_activities category into competitorClaim type', () {
      final json = <String, dynamic>{
        'id': 'fb-101',
        'category': 'competitors_activities',
        'title': 'Competitor promo in Cairo',
        'submittedAtIso': '2026-11-19T10:00:00.000Z',
        'status': 'SENT',
        'details': 'Competitor offering 2+1 promotion in pharmacies.',
      };

      final dto = FeedbackItemDto.fromJson(json);
      expect(dto.typeString, 'competitorClaim');

      final domain = dto.toDomain();
      expect(domain.type, FeedbackType.competitorClaim);
      expect(domain.details, contains('2+1 promotion'));
    });
  });
}
