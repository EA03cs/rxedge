import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/features/feedback/data/models/feedback_dto.dart';
import 'package:rxedge/features/feedback/domain/entities/feedback_entities.dart';

void main() {
  group('FeedbackItemDto Deserialization Tests', () {
    test('successfully parses live Prisma payload where product is a Map', () {
      final livePrismaPayload = <String, dynamic>{
        'id': 'c17952bd-1ea8-48dc-be9b-d5ac7adcc6cd',
        'clientSubmissionId': 'sub_live_01',
        'userId': 'user_123',
        'productId': '15a2df51-989a-4547-bc97-53455be164c8',
        'category': 'doctor_objection',
        'status': 'ANSWERED',
        'title': 'اعتراض على استقرار ضغط الدم في الصباح',
        'doctorSpecialty': 'استشاري مسالك بولية',
        'details': 'أفاد الطبيب أن حاصرات ألفا تسبب هبوط ضغط حاد في الصباح.',
        'representativeResponse': 'وضحت للطبيب أن نظام GITS يضمن تحكماً مستقراً 24 ساعة.',
        'competitorName': null,
        'competitorClaim': null,
        'attachmentUrl': null,
        'voiceNoteUrl': null,
        'createdAt': '2026-11-14T17:01:38.387Z',
        'updatedAt': '2026-11-14T17:01:38.387Z',
        'product': <String, dynamic>{
          'id': '15a2df51-989a-4547-bc97-53455be164c8',
          'brandCode': 'CARD-XL',
          'therapeuticArea': 'Cardiovascular & Urology',
          'boxImageUrl': '/uploads/products/cardura_xl.png',
          'name': 'كارديورا إكس إل',
        },
        'productName': 'كارديورا إكس إل',
        'replies': <dynamic>[
          <String, dynamic>{
            'id': 'rep_01',
            'message': 'رد علمي ممتاز ودقيق!',
            'createdAt': '2026-11-14T17:05:00.000Z',
            'repliedBy': <String, dynamic>{
              'id': 'admin_01',
              'name': 'Dr. Kareem - Medical Affairs',
              'role': 'MARKETING_ADMIN',
            },
          },
        ],
        'repliesCount': 1,
      };

      final dto = FeedbackItemDto.fromJson(livePrismaPayload);

      expect(dto.id, 'c17952bd-1ea8-48dc-be9b-d5ac7adcc6cd');
      expect(dto.typeString, 'doctorObjection');
      expect(dto.statusString, 'answered');
      expect(dto.product, 'كارديورا إكس إل');
      expect(dto.doctorSpecialty, 'استشاري مسالك بولية');
      expect(dto.objection, 'أفاد الطبيب أن حاصرات ألفا تسبب هبوط ضغط حاد في الصباح.');
      expect(dto.howResponded, 'وضحت للطبيب أن نظام GITS يضمن تحكماً مستقراً 24 ساعة.');
      expect(dto.marketingReply, 'رد علمي ممتاز ودقيق!');
      expect(dto.repliedBy, 'Dr. Kareem - Medical Affairs');

      final domain = dto.toDomain();
      expect(domain.type, FeedbackType.doctorObjection);
      expect(domain.status, FeedbackStatus.answered);
      expect(domain.product, 'كارديورا إكس إل');
    });

    test('successfully parses legacy payload where product is a String', () {
      final legacyPayload = <String, dynamic>{
        'id': 'fb_02',
        'typeString': 'competitorClaim',
        'title': 'Competitor claim',
        'submittedAtIso': '2026-11-14T10:00:00.000Z',
        'statusString': 'seen',
        'product': 'Cardura XL',
        'competitorName': 'PharmaStar',
        'claim': 'Identical efficacy',
        'whereHeard': 'Hospital meeting',
      };

      final dto = FeedbackItemDto.fromJson(legacyPayload);
      expect(dto.product, 'Cardura XL');
      expect(dto.statusString, 'seen');
      expect(dto.competitorName, 'PharmaStar');

      final domain = dto.toDomain();
      expect(domain.type, FeedbackType.competitorClaim);
      expect(domain.status, FeedbackStatus.seen);
    });
  });
}
