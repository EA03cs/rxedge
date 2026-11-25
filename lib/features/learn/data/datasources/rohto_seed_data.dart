import '../models/learning_dto.dart';

/// Official Rohto Catalog seeded directly from Excel Module 1 (Product Navigator)
abstract final class RohtoSeedData {
  /// Shared 8 FAQs for Rohto Cool (RC) and Rohto Aqua (RA) from the approved sheet.
  static const List<ProductFaqDto> _sharedAquaCoolFaqs = [
    ProductFaqDto(
      id: 'faq_ra_rc_1',
      question: 'Why are these eye drops different?',
      answer:
          'RA & RC combine multiple ingredients with a formulation of minerals and moisturizing ingredients that replenish lost minerals and moisturize the eye.',
      orderIndex: 1,
    ),
    ProductFaqDto(
      id: 'faq_ra_rc_2',
      question: 'What is the difference between RA & RC?',
      answer:
          'Rohto Aqua is a gentle lubricating eyedrop to immediately moisturizes and soothes dry eyes.\nRohto Cool is a lubricating eyedrop to moisturize and refresh the eye. Immediately provides a burst of cooling relief.',
      orderIndex: 2,
    ),
    ProductFaqDto(
      id: 'faq_ra_rc_3',
      question: 'Why are RA & RC specifically designed for CL users?',
      answer:
          'RA & RC are specifically formulated for contact lens wearers. In addition to lubricating and moisturizing the eyes, they contain ingredients that help support eye comfort during lens wear and help reduce the accumulation of deposits on contact lenses.',
      orderIndex: 3,
    ),
    ProductFaqDto(
      id: 'faq_ra_rc_4',
      question: 'Does it contain preservatives?',
      answer:
          'Yes, Polyhexamethylene Biguanide. PHMB is gentle and safe to use.',
      orderIndex: 4,
    ),
    ProductFaqDto(
      id: 'faq_ra_rc_5',
      question: 'Why choose RA/RC over any eye lubricant when using CL?',
      answer:
          'RA & RC are specifically formulated to address the needs of contact lens users by:\n* Providing lubrication and moisture.\n* Helping reduce discomfort associated with temporary corneal hypoxia during lens wear.\n* Helping inhibit deposit accumulation on contact lenses.',
      orderIndex: 5,
    ),
    ProductFaqDto(
      id: 'faq_ra_rc_6',
      question: 'Can RA/RC be used after LASIK or eye surgery?',
      answer:
          'We recommend using Rohto Aqua, as it lubricates and soothes the eyes.',
      orderIndex: 6,
    ),
    ProductFaqDto(
      id: 'faq_ra_rc_7',
      question: 'Can it be used during pregnancy and breastfeeding?',
      answer:
          'Based on the ingredients, no specific concern is expected; however, pregnant or breastfeeding patients should consult a physician if they have any concerns or symptoms.',
      orderIndex: 7,
    ),
    ProductFaqDto(
      id: 'faq_ra_rc_8',
      question: 'What causes eye drops to sting?',
      answer:
          'The "stinging" sensation may occur if the condition of the user\'s eyes is the cause (tiredness, inflammation, minor scratches) or if the user feels a strong cool sensation. Rohto eye drops have the same osmolarity and pH as tears, and the ingredients are selected for their safety.',
      orderIndex: 8,
    ),
  ];

  static const List<ProductLearningDto> products = [
    ProductLearningDto(
      id: 'prod-rohto-dry-aid',
      name: 'Rohto Dry Aid',
      therapeuticArea: 'Ophthalmology (Dry Eye)',
      productOverview:
          'Unlike most lubricating eye drops that only work on one layer of the tear film, Rohto Dry Aid with Tearshield  Technology works in a unique way to restore moisture to the tear film by working on all layers to mimic a stable, natural tear.',
      isRecommended: true,
      boxImageUrl: 'assets/images/rohto_dry_aid.png',
      positioning: ProductPositioningDto(
        keyMessage:
            'Rohto Dry Aid with Tearshield Technology formulation hydrates, protects and restores the natural tear film by working on all layers of the tear. It provides fast acting soothing relief for up to 12 hours and long-lasting hydration and protection from the symptoms of dry eye.',
        keyPositioning:
            'Rohto Dry Aid with Tearshield Technology formulation hydrates, protects and restores the natural tear film by working on all layers of the tear. It provides fast acting soothing relief for up to 12 hours and long-lasting hydration and protection from the symptoms of dry eye.',
        keyMessaging: [
          'Provides fast-acting, non-blurring dry eye relief and superior comfort.',
          'Unique formula, contains multiple ingredients that work across different layers of the tear film.',
          'Dry eye treatment with Tearshield Technology to mimic real tears and restore moisture.',
          'Relieves dryness due to electronics use, hormonal issues, environmental factors, and other irritation.',
          'Convenient 10 mLs bottle.',
          'User-friendly, no hard squeezing for the bottle.',
        ],
        targetDoctors: ['Ophthalmologists', 'Optometrists'],
        targetPatient:
            'Patients with severe dryness including patients with Meibomian Gland Dysfunction (MGD)',
        keyBenefits: [
          'Unique with all the ingredients especially Menthol and Sesame oil.',
          'Symptoms relief up to 12 hours.',
          'Available upon opening for 3 months.',
          'Powered with TEARSHIELD TECHNOLOGY. To hydrate, protect and restore the natural stability of the tear film.',
          'Works on 3 layers of the tear film.',
          'User-friendly, no hard squeezing for the bottle.',
        ],
        dosageHighlights: [
          'Convenient 10 mLs bottle.',
          'Available upon opening for 3 months.',
        ],
        proofPoints: [
          'Symptoms relief up to 12 hours.',
          'Provides fast-acting, non-blurring dry eye relief and superior comfort.',
          'Powered with TEARSHIELD TECHNOLOGY. To hydrate, protect and restore the natural stability of the tear film.',
        ],
      ),
      packShots: [
        ProductPackShotDto(
          id: 'ps_dry_aid_1',
          title: 'Rohto Dry Aid Packshot',
          imageUrl: 'assets/images/rohto_dry_aid.png',
        ),
      ],
      supportingStudies: [
        SupportingStudyDto(
          id: 'study_dry_aid_placeholder',
          title: 'Studies will be added',
          fileUrl: '',
          studyType: 'e_detailed_slides',
        ),
      ],
      faqs: [
        ProductFaqDto(
          id: 'faq_rda_1',
          question: 'What does TEARSHIELD TECHNOLOGY™ mean?',
          answer:
              'Rohto Dry Aid’s TEARSHIELD TECHNOLOGY™ restores and lubricates the natural tear film, for long-lasting relief and protection from 8 symptoms of “dry” eye.',
          orderIndex: 1,
        ),
        ProductFaqDto(
          id: 'faq_rda_2',
          question: 'Does RDA contain Povidone as antiseptic?',
          answer:
              'RDA contains Povidone not Povidone Iodine. Povidone lubricates, protects and soothes the surface of the eye and reduces damage and subsequent inflammation of the mucin area which is associated with dryness.',
          orderIndex: 2,
        ),
        ProductFaqDto(
          id: 'faq_rda_3',
          question: 'Why do you use Menthol?',
          answer:
              'Menthol is used for its refreshing sensation. Menthol contributes to the enhancement of the lipid layer as it stimulates the meibomian glands, making it suitable for patients with Meibomian Gland Dysfunction (MGD).',
          orderIndex: 3,
        ),
        ProductFaqDto(
          id: 'faq_rda_4',
          question: 'Does it contain preservatives?',
          answer:
              'Yes, Polyhexamethylene Biguanide. PHMB is gentle and safe to use.',
          orderIndex: 4,
        ),
        ProductFaqDto(
          id: 'faq_rda_5',
          question: 'Can it be used during pregnancy and breastfeeding?',
          answer:
              'Based on the ingredients, no specific concern is expected; however, pregnant or breastfeeding patients should consult a physician if they have any concerns or symptoms.',
          orderIndex: 5,
        ),
        ProductFaqDto(
          id: 'faq_rda_6',
          question: 'What causes eye drops to sting?',
          answer:
              'The "stinging" sensation may occur if the condition of the user\'s eyes is the cause (tiredness, inflammation, minor scratches) or if the user feels a strong cool sensation. Rohto eye drops have the same osmolarity and pH as tears, and the ingredients are selected for their safety.',
          orderIndex: 6,
        ),
        ProductFaqDto(
          id: 'faq_rda_7',
          question: 'How long does the efficacy of Rohto Dry Aid last for?',
          answer:
              '12 hours. It was found that the relieving effect of Rohto Dry Aid lasts from morning to evening.',
          orderIndex: 7,
        ),
        ProductFaqDto(
          id: 'faq_rda_8',
          question: 'How does Rohto Dry Aid compare with Systane Ultra?',
          answer:
              'Results from a recent clinical study showed that the subjects in the Rohto Dry Aid group experienced a superior relief from discomfort associated with visual tasking activities and daily diaries, indicating that the Rohto Dry Aid drops may provide longer lasting “dry” eye relief over the course of the day. Also, it was demonstrated that those who used Rohto Dry Aid experienced longer improvement in their BUT prolonged effect, meaning that Rohto Dry Aid helps prolong the relief efficacy which lasts longer than Systane Ultra.',
          orderIndex: 8,
        ),
        ProductFaqDto(
          id: 'faq_rda_9',
          question:
              'How does Rohto Dry Aid compare with dry eye relief drops containing Hyaluronic Acid (HA)?',
          answer:
              'Rohto Dry Aid provides replenishment to both the Lipid layer and the muco-aqueous layer. HA has hydration properties which benefit the aqueous layer only.',
          orderIndex: 9,
        ),
        ProductFaqDto(
          id: 'faq_rda_10',
          question: 'How long can I keep Rohto Dry Aid for?',
          answer: 'Discard Rohto Dry Aid 3 months after its very first opening.',
          orderIndex: 10,
        ),
        ProductFaqDto(
          id: 'faq_rda_11',
          question: 'Can Rohto Dry Aid be used with contact lenses?',
          answer:
              'Rohto Dry Aid can be used 15 to 20 minutes before using contact lenses. Remove your contact lenses, apply Rohto Dry Aid to your eyes and wait 15 to 20 minutes before wearing your contact lenses.',
          orderIndex: 11,
        ),
      ],
      lessons: [
        LessonDto(
          id: 'les_rda_1',
          productId: 'prod-rohto-dry-aid',
          productName: 'Rohto Dry Aid',
          title: 'Tearshield Technology & 3-Layer Tear Film Support',
          order: 1,
          durationMinutes: 4,
          isCompleted: false,
          isBookmarked: false,
          sections: [
            LessonSectionDto(
              title: 'Product Overview & Key Positioning',
              content:
                  'Unlike most lubricating eye drops that only work on one layer of the tear film, Rohto Dry Aid with Tearshield  Technology works in a unique way to restore moisture to the tear film by working on all layers to mimic a stable, natural tear. It provides fast acting soothing relief for up to 12 hours and long-lasting hydration and protection from the symptoms of dry eye.',
              keyTakeaway: 'Symptoms relief up to 12 hours.',
            ),
            LessonSectionDto(
              title: 'Key Benefits & Usage Highlights',
              content:
                  'Unique with all the ingredients especially Menthol and Sesame oil. Works on 3 layers of the tear film. Convenient 10 mLs bottle. User-friendly, no hard squeezing for the bottle. Available upon opening for 3 months.',
              keyTakeaway:
                  'Powered with TEARSHIELD TECHNOLOGY. To hydrate, protect and restore the natural stability of the tear film.',
            ),
          ],
        ),
      ],
      competitors: [
        CompetitorComparisonDto(
          id: 'comp_systane',
          competitorName: 'Systane Ultra',
          theirClaim: 'Dry eye relief drop.',
          howToRespond:
              'Rohto Dry Aid drops may provide longer lasting “dry” eye relief over the course of the day and help prolong the relief efficacy which lasts longer than Systane Ultra.',
          proofReference:
              'Results from a recent clinical study showed that the subjects in the Rohto Dry Aid group experienced a superior relief from discomfort associated with visual tasking activities and daily diaries, and longer improvement in their BUT prolonged effect.',
        ),
        CompetitorComparisonDto(
          id: 'comp_ha_drops',
          competitorName: 'Hyaluronic Acid (HA) Drops',
          theirClaim: 'Dry eye relief drops containing Hyaluronic Acid (HA).',
          howToRespond:
              'Rohto Dry Aid provides replenishment to both the Lipid layer and the muco-aqueous layer. HA has hydration properties which benefit the aqueous layer only.',
          proofReference:
              'Rohto Dry Aid FAQ: Comparison with dry eye relief drops containing Hyaluronic Acid (HA).',
        ),
      ],
    ),
    ProductLearningDto(
      id: 'prod-rohto-cool',
      name: 'Rohto Cool',
      therapeuticArea: 'Ophthalmology (Eye Strain & Refreshing)',
      productOverview:
          'Lubricating eye drop to moisturize and “refresh” eye. Immediately provides a burst of cooling relief.',
      isRecommended: false,
      boxImageUrl: 'assets/images/rohto_cool.png',
      positioning: ProductPositioningDto(
        keyMessage:
            'Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Cool can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
        keyPositioning:
            'Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Cool can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
        keyMessaging: [
          'Cooling & refreshing effect.',
          'Convenient 13 mLs bottle.',
          'Contains a good balance of minerals and moisturizing ingredients that replenish lost minerals and moisturize dry eyes.',
          'Inspired by healthy human tears providing moisture and relief for dry eye',
          'Suitable for contact lens',
        ],
        targetDoctors: ['Ophthalmologists', 'Optometrists'],
        targetPatient:
            'Patients with mild/moderate dryness, patients who wear contact lenses and experience Contact Lens–Associated Dry Eye Disease (CLADE)',
        keyBenefits: [
          'Retains moisture & improves quality of tears.',
          'Can be used with all contact lenses',
          'Cooling eye drop that delivers instant cooling and refreshes the eyes.',
          'Replenish tears and lost minerals.',
          'Specifically formulated to address the needs of contact lens users by:',
          '1. Providing lubrication and moisture.',
          '2. Helping reduce discomfort associated with temporary corneal hypoxia during lens wear.',
          '3. Helping inhibit deposit accumulation on contact lenses.',
        ],
        dosageHighlights: [
          'Suitable for contact lens',
          'Convenient 13 mLs bottle.',
        ],
        proofPoints: [
          'Cooling eye drop that delivers instant cooling and refreshes the eyes.',
          'Replenish tears and lost minerals.',
        ],
      ),
      packShots: [
        ProductPackShotDto(
          id: 'ps_cool_1',
          title: 'Rohto Cool Packshot',
          imageUrl: 'assets/images/rohto_cool.png',
        ),
      ],
      supportingStudies: [
        SupportingStudyDto(
          id: 'study_cool_placeholder',
          title: 'Studies will be added',
          fileUrl: '',
          studyType: 'e_detailed_slides',
        ),
      ],
      faqs: _sharedAquaCoolFaqs,
      lessons: [
        LessonDto(
          id: 'les_cool_1',
          productId: 'prod-rohto-cool',
          productName: 'Rohto Cool',
          title: 'Cooling & Refreshing Relief for Eye Strain & CLADE',
          order: 1,
          durationMinutes: 4,
          isCompleted: false,
          isBookmarked: false,
          sections: [
            LessonSectionDto(
              title: 'Product Overview & Key Positioning',
              content:
                  'Lubricating eye drop to moisturize and “refresh” eye. Immediately provides a burst of cooling relief. Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Cool can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
              keyTakeaway:
                  'Cooling eye drop that delivers instant cooling and refreshes the eyes.',
            ),
            LessonSectionDto(
              title: 'Key Benefits for Contact Lens Users',
              content:
                  'Contains a good balance of minerals and moisturizing ingredients that replenish lost minerals and moisturize dry eyes. Specifically formulated to address the needs of contact lens users by: 1. Providing lubrication and moisture. 2. Helping reduce discomfort associated with temporary corneal hypoxia during lens wear. 3. Helping inhibit deposit accumulation on contact lenses.',
              keyTakeaway:
                  'Retains moisture & improves quality of tears. Can be used with all contact lenses.',
            ),
          ],
        ),
      ],
      competitors: [],
    ),
    ProductLearningDto(
      id: 'prod-rohto-aqua',
      name: 'Rohto Aqua',
      therapeuticArea: 'Ophthalmology (Gentle Lubricating & Soothing)',
      productOverview:
          'Gentle lubricating eye drop to immediately moisturize and soothe dry eyes. Assists in retaining moisture and improve quality of tears.',
      isRecommended: false,
      boxImageUrl: 'assets/images/rohto_aqua.png',
      positioning: ProductPositioningDto(
        keyMessage:
            'Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Aqua can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
        keyPositioning:
            'Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Aqua can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
        keyMessaging: [
          'Soothing & moisturizing effect.',
          'Convenient 13 mls bottle.',
          'Contains a good balance of minerals and moisturizing ingredients that replenish lost minerals and moisturize dry eyes.',
          'Inspired by healthy human tears providing moisture and relief for dry eye',
        ],
        targetDoctors: ['Ophthalmologists', 'Optometrists'],
        targetPatient:
            'Patients with mild/moderate dryness, patients who wear contact lenses and experience Contact Lens–Associated Dry Eye Disease (CLADE)',
        keyBenefits: [
          'Retains moisture & improves quality of tears.',
          'Can be used with all contact lenses',
          'Soothing and moisturizing effect.',
          'Replenish tears and lost minerals.',
          'Specifically formulated to address the needs of contact lens users by:',
          '1. Providing lubrication and moisture.',
          '2. Helping reduce discomfort associated with temporary corneal hypoxia during lens wear.',
          '3. Helping inhibit deposit accumulation on contact lenses.',
        ],
        dosageHighlights: [
          'Can be used with all contact lenses',
          'Convenient 13 mLs bottle.',
        ],
        proofPoints: [
          'Can be used with all contact lenses.',
          'Replenish tears and lost minerals.',
        ],
      ),
      packShots: [
        ProductPackShotDto(
          id: 'ps_aqua_1',
          title: 'Rohto Aqua Packshot',
          imageUrl: 'assets/images/rohto_aqua.png',
        ),
      ],
      supportingStudies: [
        SupportingStudyDto(
          id: 'study_aqua_placeholder',
          title: 'Studies will be added',
          fileUrl: '',
          studyType: 'e_detailed_slides',
        ),
      ],
      faqs: _sharedAquaCoolFaqs,
      lessons: [
        LessonDto(
          id: 'les_aqua_1',
          productId: 'prod-rohto-aqua',
          productName: 'Rohto Aqua',
          title: 'Soothing & Moisturizing Relief for Eye Strain & CLADE',
          order: 1,
          durationMinutes: 4,
          isCompleted: false,
          isBookmarked: false,
          sections: [
            LessonSectionDto(
              title: 'Product Overview & Key Positioning',
              content:
                  'Gentle lubricating eye drop to immediately moisturize and soothe dry eyes. Assists in retaining moisture and improve quality of tears. Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Aqua can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
              keyTakeaway:
                  'Inspired by healthy human tears providing moisture and relief for dry eye.',
            ),
            LessonSectionDto(
              title: 'Key Benefits for Contact Lens Users',
              content:
                  'Contains a good balance of minerals and moisturizing ingredients that replenish lost minerals and moisturize dry eyes. Specifically formulated to address the needs of contact lens users by: 1. Providing lubrication and moisture. 2. Helping reduce discomfort associated with temporary corneal hypoxia during lens wear. 3. Helping inhibit deposit accumulation on contact lenses.',
              keyTakeaway:
                  'Retains moisture & improves quality of tears. Can be used with all contact lenses.',
            ),
          ],
        ),
      ],
      competitors: [],
    ),
  ];
}
