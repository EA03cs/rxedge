import '../models/learning_dto.dart';

/// Official Rohto Catalog seeded directly from Excel Module 1 (Product Navigator)
abstract final class RohtoSeedData {
  static const List<ProductLearningDto> products = [
    ProductLearningDto(
      id: 'prod-rohto-dry-aid',
      name: 'Rohto Dry Aid',
      therapeuticArea: 'Ophthalmology (Dry Eye)',
      productOverview:
          'Unlike most lubricating eye drops that only work on one layer of the tear film, Rohto Dry Aid with Tearshield  Technology works in a unique way to restore moisture to the tear film by working on all layers to mimic a stable, natural tear.',
      isRecommended: true,
      boxImageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
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
          'Convenient 10 ml container.',
          'Available upon opening for 3 months.'
        ],
        proofPoints: [
          'Relieves symptoms up to 12 hours.',
          'Provides non-blurring dry eye relief and superior comfort.',
          'Powered with TEARSHIELD TECHNOLOGY to lubricate, protect and restore natural tear film.',
        ],
      ),
      packShots: [
        ProductPackShotDto(
          id: 'ps_dry_aid_1',
          title: 'Front Packshot',
          imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
        ),
        ProductPackShotDto(
          id: 'ps_dry_aid_2',
          title: 'Bottle Packshot',
          imageUrl: 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=500',
        ),
      ],
      supportingStudies: [
        SupportingStudyDto(
          id: 'study_dry_aid_1',
          title: 'Rohto Dry Aid Tearshield Clinical Evaluation & Detailing Material',
          fileUrl:
              'https://drive.google.com/file/d/1jaenvaltpOhA0x82DN2OHV39twZn9ms-/view?usp=drive_link',
          studyType: 'e_detailed_slides',
        ),
      ],
      faqs: [
        ProductFaqDto(
          id: 'faq_rda_1',
          question: 'What does TEARSHIELD TECHNOLOGY™ mean?',
          answer:
              'Rohto Dry Aid’s TEARSHIELD TECHNOLOGY™ restores and lubricates the natural tear film, for long-lasting relief and protection from 8 symptoms of “dry” eye.',
        ),
        ProductFaqDto(
          id: 'faq_rda_2',
          question: 'Does RDA contain Povidone as antiseptic?',
          answer:
              'RDA contains Povidone not Povidone Iodine. Povidone lubricates, protects and soothes the surface of the eye and reduces damage and subsequent inflammation of the mucin area which is associated with dryness.',
        ),
        ProductFaqDto(
          id: 'faq_rda_3',
          question: 'Why do you use Menthol?',
          answer:
              'Menthol is used for its refreshing sensation. Menthol contributes to the enhancement of the lipid layer as it stimulates the meibomian glands, making it suitable for patients with Meibomian Gland Dysfunction (MGD).',
        ),
        ProductFaqDto(
          id: 'faq_rda_4',
          question: 'Does it contain preservatives?',
          answer: 'Yes, Polyhexamethylene Biguanide. PHMB is gentle and safe to use.',
        ),
        ProductFaqDto(
          id: 'faq_rda_5',
          question: 'Can it be used during pregnancy and breastfeeding?',
          answer:
              'Based on the ingredients, no specific concern is expected; however, pregnant or breastfeeding patients should consult a physician if they have any concerns or symptoms.',
        ),
        ProductFaqDto(
          id: 'faq_rda_6',
          question: 'What causes eye drops to sting?',
          answer:
              'The "stinging" sensation may occur if the condition of the user\'s eyes is the cause (tiredness, inflammation, minor scratches) or if the user feels a strong cool sensation. Rohto eye drops have the same osmolarity and pH as tears, and the ingredients are selected for their safety.',
        ),
        ProductFaqDto(
          id: 'faq_rda_7',
          question: 'How long does the efficacy of Rohto Dry Aid last for?',
          answer:
              '12 hours. It was found that the relieving effect of Rohto Dry Aid lasts from morning to evening.',
        ),
        ProductFaqDto(
          id: 'faq_rda_8',
          question: 'How does Rohto Dry Aid compare with Systane Ultra?',
          answer:
              'Results from a recent clinical study showed that the subjects in the Rohto Dry Aid group experienced a superior relief from discomfort associated with visual tasking activities and daily diaries, indicating that the Rohto Dry Aid drops may provide longer lasting “dry” eye relief over the course of the day. Also, it was demonstrated that those who used Rohto Dry Aid experienced longer improvement in their BUT prolonged effect, meaning that Rohto Dry Aid helps prolong the relief efficacy which lasts longer than Systane Ultra.',
        ),
        ProductFaqDto(
          id: 'faq_rda_9',
          question:
              'How does Rohto Dry Aid compare with dry eye relief drops containing Hyaluronic Acid (HA)?',
          answer:
              'Rohto Dry Aid provides replenishment to both the Lipid layer and the muco-aqueous layer. HA has hydration properties which benefit the aqueous layer only.',
        ),
        ProductFaqDto(
          id: 'faq_rda_10',
          question: 'How long can I keep Rohto Dry Aid for?',
          answer: 'Discard Rohto Dry Aid 3 months after its very first opening.',
        ),
        ProductFaqDto(
          id: 'faq_rda_11',
          question: 'Can Rohto Dry Aid be used with contact lenses?',
          answer:
              'Rohto Dry Aid can be used 15 to 20 minutes before using contact lenses. Remove your contact lenses, apply Rohto Dry Aid to your eyes and wait 15 to 20 minutes before wearing your contact lenses.',
        ),
      ],
      lessons: [
        LessonDto(
          id: 'les_rda_1',
          productId: 'prod-rohto-dry-aid',
          productName: 'Rohto Dry Aid',
          title: 'Tearshield Technology™ & Triple Layer Restoration',
          order: 1,
          durationMinutes: 4,
          isCompleted: false,
          isBookmarked: false,
          sections: [
            LessonSectionDto(
              title: 'Triple Layer Tear Restoration',
              content:
                  'Rohto Dry Aid works in a unique way to restore moisture to the tear film by working on all 3 layers (lipid, aqueous, mucin) to mimic a stable, natural tear.',
              keyTakeaway: 'Relieves symptoms for up to 12 hours.',
            ),
          ],
        ),
      ],
      competitors: [
        CompetitorComparisonDto(
          id: 'comp_systane',
          competitorName: 'Systane Ultra',
          theirClaim: 'Fast relief with HP-Guar delivery.',
          howToRespond:
              'Rohto Dry Aid provides longer lasting relief across the entire day (up to 12 hours) and contains Sesame oil and Menthol to invigorate the meibomian glands.',
          proofReference:
              'Results from a recent clinical study showed that the subjects in the Rohto Dry Aid group experienced superior relief over the course of the day.',
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
      boxImageUrl: 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=500',
      positioning: ProductPositioningDto(
        keyMessage:
            'Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Cool can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
        keyPositioning:
            'Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Cool can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
        keyMessaging: [
          'Cooling & refreshing effect.',
          'Convenient 13 mLs bottle.',
          'Contains a good balance of minerals and moisturizing         ingredients that replenish lost minerals and moisturize dry eyes.',
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
          'Suitable for contact lens users.',
          'Convenient 13 ml container.'
        ],
        proofPoints: [
          'Immediate cooling eye drop that delivers extra cooling and refreshes the eyes.',
          'Replenish tears and lost minerals.',
        ],
      ),
      packShots: [
        ProductPackShotDto(
          id: 'ps_cool_1',
          title: 'Rohto Cool Packshot',
          imageUrl: 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=500',
        ),
      ],
      supportingStudies: [
        SupportingStudyDto(
          id: 'study_cool_1',
          title: 'Rohto Cool Detailing Material',
          fileUrl:
              'https://drive.google.com/file/d/1MYbkjhlgiovvJe7AE_XIGPVhg2YlZZ9l/view?usp=sharing',
          studyType: 'e_detailed_slides',
        ),
      ],
      faqs: [
        ProductFaqDto(
          id: 'faq_cool_1',
          question: 'Why are these eye drops different?',
          answer:
              'RA & RC combine multiple ingredients with a formulation of minerals and moisturizing ingredients that replenish lost minerals and moisturize the eye.',
        ),
        ProductFaqDto(
          id: 'faq_cool_2',
          question: 'What is the difference between RA & RC?',
          answer:
              'Rohto Aqua is a gentle lubricating eyedrop to immediately moisturizes and soothes dry eyes.\nRohto Cool is a lubricating eyedrop to moisturize and refresh the eye. Immediately provides a burst of cooling relief.',
        ),
        ProductFaqDto(
          id: 'faq_cool_3',
          question: 'Why are RA & RC specifically designed for CL users?',
          answer:
              'RA & RC are specifically formulated for contact lens wearers. In addition to lubricating and moisturizing the eyes, they contain ingredients that help support eye comfort during lens wear and help reduce the accumulation of deposits on contact lenses.',
        ),
        ProductFaqDto(
          id: 'faq_cool_4',
          question: 'Does it contain preservatives?',
          answer:
              'Yes, Polyhexamethylene Biguanide. PHMB is gentle and safe to use.',
        ),
        ProductFaqDto(
          id: 'faq_cool_5',
          question: 'Why choose RA/RC over any eye lubricant when using CL?',
          answer:
              'RA & RC are specifically formulated to address the needs of contact lens users by:\n* Providing lubrication and moisture.\n* Helping reduce discomfort associated with temporary corneal hypoxia during lens wear.\n* Helping inhibit deposit accumulation on contact lenses.',
        ),
        ProductFaqDto(
          id: 'faq_cool_6',
          question: 'Can RA/RC be used after LASIK or eye surgery?',
          answer:
              'We recommend using Rohto Aqua, as it lubricates and soothes the eyes.',
        ),
        ProductFaqDto(
          id: 'faq_cool_7',
          question: 'Can it be used during pregnancy and breastfeeding?',
          answer:
              'Based on the ingredients, no specific concern is expected; however, pregnant or breastfeeding patients should consult a physician if they have any concerns or symptoms.',
        ),
        ProductFaqDto(
          id: 'faq_cool_8',
          question: 'What causes eye drops to sting?',
          answer:
              'The "stinging" sensation may occur if the condition of the user\'s eyes is the cause (tiredness, inflammation, minor scratches) or if the user feels a strong cool sensation. Rohto eye drops have the same osmolarity and pH as tears, and the ingredients are selected for their safety.',
        ),
      ],
      lessons: [
        LessonDto(
          id: 'les_cool_1',
          productId: 'prod-rohto-cool',
          productName: 'Rohto Cool',
          title: 'Refreshing Relief & Digital Eye Strain Countermeasures',
          order: 1,
          durationMinutes: 4,
          isCompleted: false,
          isBookmarked: false,
          sections: [
            LessonSectionDto(
              title: 'Cooling Action & Corneal Microcirculation',
              content:
                  'Rohto Cool combines targeted cooling relief with essential electrolyte replenishment to soothe digital eye strain and irritation.',
              keyTakeaway:
                  'Instant refreshing cooling and tear film rebalancing.',
            ),
          ],
        ),
      ],
      competitors: [
        CompetitorComparisonDto(
          id: 'comp_refresh',
          competitorName: 'Refresh Tears (Carboxymethylcellulose)',
          theirClaim: 'Standard OTC saline lubricating drop.',
          howToRespond:
              'Rohto Cool delivers an invigorating cooling sensation and balanced mineral hydration beyond plain saline.',
          proofReference:
              'Clinical feedback demonstrates high satisfaction and immediate relief for computer vision fatigue.',
        ),
      ],
    ),
    ProductLearningDto(
      id: 'prod-rohto-aqua',
      name: 'Rohto Aqua',
      therapeuticArea: 'Ophthalmology (Gentle Lubricating & Soothing)',
      productOverview:
          'Gentle lubricating eye drop to immediately moisturize and soothe dry eyes. Assists in retaining moisture and improve quality of tears.',
      isRecommended: false,
      boxImageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
      positioning: ProductPositioningDto(
        keyMessage:
            'Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Aqua can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
        keyPositioning:
            'Use for eye-strain symptoms appear due to long exposure to digital screens, reading, driving, or airconditioned places. Rohto Aqua can also be used to ease eye discomfort and irritation due to smoke, dust, wind, sun glare, and chlorinated water. Also works well even for those with contact lenses on.',
        keyMessaging: [
          'Soothing & moisturizing effect.',
          'Convenient 13 mls bottle.',
          'Contains a good balance of minerals and moisturizing         ingredients that replenish lost minerals and moisturize dry eyes.',
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
          'Convenient 13 ml bottle.',
          'Safe after LASIK or eye surgery.'
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
          imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
        ),
      ],
      supportingStudies: [],
      faqs: [],
      lessons: [
        LessonDto(
          id: 'les_aqua_1',
          productId: 'prod-rohto-aqua',
          productName: 'Rohto Aqua',
          title: 'Gentle Ocular Hydration & Natural Tear Mimicry',
          order: 1,
          durationMinutes: 4,
          isCompleted: false,
          isBookmarked: false,
          sections: [
            LessonSectionDto(
              title: 'Natural Tear Composition & pH Balance',
              content:
                  'Rohto Aqua is formulated with a precise electrolyte and mineral balance mimicking human basal tears. It rehydrates the cornea without stinging or burning sensations, making it the ideal starter artificial tear for sensitive eyes.',
              keyTakeaway:
                  'Matches natural tear osmolarity and pH for sting-free hydration.',
            ),
            LessonSectionDto(
              title: 'Compatibility with All Contact Lens Types',
              content:
                  'Unlike high-viscosity gels or drops containing aggressive preservatives, Rohto Aqua can be safely instilled directly over soft, hard, and silicone hydrogel contact lenses to combat Contact Lens-Associated Dry Eye (CLADE).',
              keyTakeaway:
                  'Safe with all contact lenses without lens removal or clouding.',
            ),
          ],
        ),
        LessonDto(
          id: 'les_aqua_2',
          productId: 'prod-rohto-aqua',
          productName: 'Rohto Aqua',
          title: 'Post-Refractive Care & Sensitive Eye Protocol',
          order: 2,
          durationMinutes: 3,
          isCompleted: false,
          isBookmarked: false,
          sections: [
            LessonSectionDto(
              title: 'Post-LASIK & Post-SMILE Corneal Soothing',
              content:
                  'Following corneal refractive surgery, transient nerve transection impairs normal tear reflex loop. Rohto Aqua provides immediate soothing moisture that supports epithelial healing without causing visual blur.',
              keyTakeaway:
                  'Recommended post-LASIK/PRK for gentle, non-irritating soothing.',
            ),
          ],
        ),
      ],
      competitors: [
        CompetitorComparisonDto(
          id: 'comp_refresh',
          competitorName: 'Refresh Tears (Carboxymethylcellulose)',
          theirClaim: 'Standard OTC saline lubricating drop.',
          howToRespond:
              'Rohto Aqua delivers a scientifically balanced electrolyte profile inspired by healthy human tears, providing longer comfort without stinging or residue.',
          proofReference:
              'In clinical evaluations, patients reported significantly higher comfort and zero stinging with Rohto Aqua compared to standard saline drops.',
        ),
      ],
    ),
  ];
}
