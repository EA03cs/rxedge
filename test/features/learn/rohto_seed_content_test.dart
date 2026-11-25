import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/features/learn/data/datasources/rohto_seed_data.dart';
import 'package:rxedge/features/learn/data/models/learning_dto.dart';

void main() {
  ProductLearningDto findProduct(String id) {
    return RohtoSeedData.products.firstWhere((p) => p.id == id);
  }

  group('RohtoSeedData & Feature Content Alignment (C1-C4)', () {
    test('Dry Aid has 11 FAQs, Cool has 8 FAQs, and Aqua has 8 FAQs identical to Cool', () {
      final dryAid = findProduct('prod-rohto-dry-aid');
      final cool = findProduct('prod-rohto-cool');
      final aqua = findProduct('prod-rohto-aqua');

      expect(dryAid.faqs.length, 11);
      expect(cool.faqs.length, 8);
      expect(aqua.faqs.length, 8);

      // Shared const list ensures identical FAQ entries for Cool and Aqua.
      expect(identical(cool.faqs, aqua.faqs), isTrue);
      for (var i = 0; i < cool.faqs.length; i++) {
        expect(aqua.faqs[i].question, cool.faqs[i].question);
        expect(aqua.faqs[i].answer, cool.faqs[i].answer);
      }

      // Exact Q6 answer per approved sheet.
      expect(cool.faqs[5].question, 'Can RA/RC be used after LASIK or eye surgery?');
      expect(
        cool.faqs[5].answer,
        'We recommend using Rohto Aqua, as it lubricates and soothes the eyes.',
      );
      expect(
        aqua.faqs[5].answer,
        'We recommend using Rohto Aqua, as it lubricates and soothes the eyes.',
      );
    });

    test('Zero banned unapproved claim strings or images.unsplash.com in lib/features/learn and lib/features/home', () {
      const bannedPhrases = [
        'images.unsplash.com',
        'Safe after LASIK or eye surgery',
        'Recommended post-LASIK/PRK',
        'Post-LASIK & Post-SMILE Corneal Soothing',
        'rehydrates the cornea without stinging',
        'sting-free',
        'zero stinging',
        'without stinging',
        'without sting',
        'aggressive preservatives',
        'silicone hydrogel',
        'without lens removal or clouding',
        'ideal starter',
        'Refresh Tears',
        'Carboxymethylcellulose',
        'high satisfaction',
        'Corneal Microcirculation',
        'tear film rebalancing',
      ];

      final directories = [
        Directory('lib/features/learn'),
        Directory('lib/features/home'),
      ];

      for (final dir in directories) {
        expect(dir.existsSync(), isTrue, reason: '${dir.path} must exist');
        final dartFiles = dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));

        for (final file in dartFiles) {
          final content = file.readAsStringSync();
          final lowerContent = content.toLowerCase();
          for (final banned in bannedPhrases) {
            expect(
              lowerContent.contains(banned.toLowerCase()),
              isFalse,
              reason: 'Found banned phrase "$banned" in ${file.path}',
            );
          }
        }
      }
    });

    test('Exact bottle sizes (10 mLs, 13 mLs), CLADE target patient, studies placeholder, and local assets', () {
      final dryAid = findProduct('prod-rohto-dry-aid');
      final cool = findProduct('prod-rohto-cool');
      final aqua = findProduct('prod-rohto-aqua');

      // Bottle sizes & durations
      expect(dryAid.positioning.keyMessaging, contains('Convenient 10 mLs bottle.'));
      expect(dryAid.positioning.dosageHighlights, contains('Convenient 10 mLs bottle.'));
      expect(dryAid.positioning.dosageHighlights, contains('Available upon opening for 3 months.'));
      expect(dryAid.positioning.effectiveKeyPositioning, contains('12 hours'));

      expect(cool.positioning.keyMessaging, contains('Convenient 13 mLs bottle.'));
      expect(cool.positioning.dosageHighlights, contains('Convenient 13 mLs bottle.'));

      expect(aqua.positioning.dosageHighlights, contains('Convenient 13 mLs bottle.'));
      expect(aqua.positioning.keyMessaging, contains('Convenient 13 mls bottle.'));

      // Target patient exact sheet text (en-dash in sheet normalized to hyphen for check too)
      const expectedCladeTarget =
          'Patients with mild/moderate dryness, patients who wear contact lenses and experience Contact Lens–Associated Dry Eye Disease (CLADE)';
      expect(cool.positioning.targetPatient, expectedCladeTarget);
      expect(aqua.positioning.targetPatient, expectedCladeTarget);
      expect(
        aqua.positioning.targetPatient!.replaceAll('\u2013', '-'),
        contains('Contact Lens-Associated Dry Eye Disease (CLADE)'),
      );

      // Supporting studies placeholder & local assets
      for (final product in [dryAid, cool, aqua]) {
        expect(product.supportingStudies.length, 1);
        expect(product.supportingStudies.first.title, 'Studies will be added');
        expect(product.supportingStudies.first.fileUrl, isEmpty);
        expect(product.boxImageUrl, startsWith('assets/images/'));
        expect(product.packShots, isNotEmpty);
        for (final ps in product.packShots) {
          expect(ps.imageUrl, startsWith('assets/images/'));
        }
      }

      // Competitors: Dry Aid keeps Systane Ultra & HA Drops; Cool & Aqua have none
      expect(
        dryAid.competitors.map((c) => c.competitorName),
        containsAll(['Systane Ultra', 'Hyaluronic Acid (HA) Drops']),
      );
      expect(cool.competitors, isEmpty);
      expect(aqua.competitors, isEmpty);
    });
  });
}
