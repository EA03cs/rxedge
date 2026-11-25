import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/features/learn/domain/entities/learning_entities.dart';
import 'package:rxedge/features/learn/presentation/screens/product_learning_screen.dart';

void main() {
  const sampleRohtoProduct = ProductLearningEntity(
    id: 'prod-dry-aid',
    name: 'Rohto Dry Aid',
    therapeuticArea: 'Ophthalmology',
    positioning: ProductPositioningEntity(
      keyMessage: 'Fast acting, long lasting relief for dry eye',
      targetDoctors: ['Ophthalmologists', 'Optometrists'],
      targetPatient: 'Patients with severe Dryness including Meibomian Gland Dysfunction (MGD)',
      keyBenefits: ['Unique with all the ingredients especially Menthol and Sesame oil.'],
      dosageHighlights: ['Convenient 10 ml container.'],
      proofPoints: ['Relieves symptoms up to 12 hours.'],
    ),
    competitors: [],
    lessons: [],
    packShots: [
      ProductPackShotEntity(
        id: 'ps_1',
        title: 'Front Packshot',
        imageUrl: 'https://drive.google.com/uc?id=sample_packshot_1',
      ),
      ProductPackShotEntity(
        id: 'ps_2',
        title: 'Bottle Packshot',
        imageUrl: 'https://drive.google.com/uc?id=sample_packshot_2',
      ),
    ],
    supportingStudies: [
      SupportingStudyEntity(
        id: 'study_1',
        title: 'Clinical Evaluation of Rohto Dry Aid vs Systane Ultra',
        fileUrl: 'https://drive.google.com/file/d/sample_study/view',
      ),
    ],
    faqs: [
      ProductFaqEntity(
        id: 'faq_1',
        question: 'What does TEARSHIELD TECHNOLOGY mean?',
        answer: 'Restores and lubricates the natural tear film for long-lasting relief.',
      ),
      ProductFaqEntity(
        id: 'faq_2',
        question: 'Why do you use Menthol?',
        answer: 'Menthol stimulates the meibomian glands, making it suitable for MGD.',
      ),
    ],
  );

  Widget buildEnglishScreen() {
    return const ProviderScope(
      child: MaterialApp(
        themeMode: ThemeMode.light,
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [Locale('en')],
        home: ProductLearningScreen(product: sampleRohtoProduct),
      ),
    );
  }

  group('ProductLearningScreen Automated Tests (Module 1: Product Navigator)', () {
    testWidgets('renders 3 tabs and displays Target Patient card in Positioning tab', (tester) async {
      await tester.pumpWidget(buildEnglishScreen());
      await tester.pumpAndSettle();

      // Product Title
      expect(find.text('Rohto Dry Aid'), findsWidgets);

      // 3 Tabs in English
      expect(find.text('Product Positioning'), findsOneWidget);
      expect(find.text('Competitive Handling'), findsOneWidget);
      expect(find.text('FAQs & Studies'), findsOneWidget);

      // Target Patient card from Excel
      expect(find.text('Target Patient'), findsOneWidget);
      expect(
        find.text('Patients with severe Dryness including Meibomian Gland Dysfunction (MGD)'),
        findsOneWidget,
      );

      // Key Benefits
      expect(find.text('Key Benefits'), findsOneWidget);
      expect(
        find.text('Unique with all the ingredients especially Menthol and Sesame oil.'),
        findsOneWidget,
      );
    });

    testWidgets('switching to FAQs & Studies tab renders packshots, studies, and expandable FAQs',
        (tester) async {
      await tester.pumpWidget(buildEnglishScreen());
      await tester.pumpAndSettle();

      // Tap on the 3rd tab: 'FAQs & Studies'
      await tester.tap(find.text('FAQs & Studies'));
      await tester.pumpAndSettle();

      // Verify Packshots gallery section
      expect(find.text('Pack Shots'), findsOneWidget);
      expect(find.text('Front Packshot'), findsOneWidget);
      expect(find.text('Bottle Packshot'), findsOneWidget);

      // Verify Supporting Studies section
      expect(find.text('Supporting Clinical Studies'), findsOneWidget);
      expect(
        find.text('Clinical Evaluation of Rohto Dry Aid vs Systane Ultra'),
        findsOneWidget,
      );
      expect(find.byTooltip('Open Study'), findsOneWidget);

      // Verify Clinical FAQs section
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('What does TEARSHIELD TECHNOLOGY mean?'), findsOneWidget);
      expect(find.text('Why do you use Menthol?'), findsOneWidget);

      // Expand first FAQ
      await tester.tap(find.text('What does TEARSHIELD TECHNOLOGY mean?'));
      await tester.pumpAndSettle();

      // Verify Answer is revealed
      expect(
        find.text('Restores and lubricates the natural tear film for long-lasting relief.'),
        findsOneWidget,
      );
    });

    testWidgets('renders Studies will be added placeholder without Open Study icon when fileUrl is empty',
        (tester) async {
      final placeholderProduct = sampleRohtoProduct.copyWith(
        supportingStudies: const [
          SupportingStudyEntity(
            id: 'study_placeholder',
            title: 'Studies will be added',
            fileUrl: '',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.light,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('en')],
            home: ProductLearningScreen(product: placeholderProduct),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('FAQs & Studies'));
      await tester.pumpAndSettle();

      expect(find.text('Studies will be added'), findsOneWidget);
      expect(find.byTooltip('Open Study'), findsNothing);
    });
  });
}
