import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/learning_dto.dart';

/// Remote Datasource Contract for Smart Learning Hub
abstract class LearnRemoteDatasource {
  Future<List<ProductLearningDto>> getProducts();
}

/// Remote Datasource Implementation with realistic clinical training data
class LearnRemoteDatasourceImpl implements LearnRemoteDatasource {
  final Dio? dio;
  final bool simulateError;

  LearnRemoteDatasourceImpl({
    this.dio,
    this.simulateError = false,
  });

  @override
  Future<List<ProductLearningDto>> getProducts() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve learning modules from remote server');
    }

    // Realistic network latency simulation
    await Future<void>.delayed(const Duration(milliseconds: 160));

    return [
      // 1. Cardura XL (Recommended, In-Progress: 3 of 6 completed)
      const ProductLearningDto(
        id: 'prod_cardura_xl',
        name: 'Cardura XL',
        therapeuticArea: 'Hypertension & BPH',
        isRecommended: true,
        positioning: ProductPositioningDto(
          keyMessage:
              'The only once-daily gastrointestinal therapeutic system (GITS) providing continuous 24-hour blood pressure control with concomitant lower urinary tract symptom relief.',
          targetDoctors: [
            'Cardiologists managing refractory nocturnal hypertension',
            'Urologists treating hypertensive men with BPH urinary symptoms',
            'Internal Medicine consultants seeking single-pill multi-morbid simplicity',
            'Geriatric specialists managing elderly polypharmacy reduction',
          ],
          keyBenefits: [
            '24-Hour continuous plasma concentration stability without peak-to-trough spikes',
            'Restores physiological nocturnal dipping to prevent early morning cardiovascular events',
            'Dual symptom relief: simultaneous blood pressure reduction and urinary flow score improvement',
            'Lipid-neutral profile with zero adverse impact on glycemic or erectile function',
          ],
          dosageHighlights: [
            'Standard starting dose: 4mg once daily taken with breakfast',
            'Titration schedule: May increase to 8mg after 4 consecutive weeks of baseline evaluation',
            'Zero dose adjustment required in renal impairment (CKD Stages 1 through 4) or geriatric patients',
            'Administration requirement: Must be swallowed whole with fluid; do not chew, divide, or crush',
          ],
          proofPoints: [
            'PREDICT Study (n=1,240): 24h ABPM demonstrated 14.2 mm Hg systolic reduction with complete morning surge suppression',
            'ALLHAT Trial Sub-analysis: Comparable cardiovascular safety to chlorthalidone with significant IPSS urinary score drop of -4.8 points',
            'Co-morbidity Registry: 82% of hypertensive BPH patients avoided initiating a second distinct alpha-blocker',
          ],
        ),
        competitors: [
          CompetitorComparisonDto(
            id: 'comp_crd_01',
            competitorName: 'Generic Amlodipine 5mg / 10mg',
            theirClaim:
                'Generic amlodipine is widely prescribed, inexpensive, and sufficient as first-line calcium channel blocker monotherapy for essential hypertension.',
            howToRespond:
                'Acknowledge amlodipine efficacy, then pivot to tolerability: amlodipine induces dose-dependent peripheral ankle edema in up to 15% of patients leading to early abandonment, and provides zero benefit for concomitant BPH symptoms. Cardura XL delivers continuous 24h control without peripheral edema and addresses BPH in one tablet.',
            proofReference:
                'ASCOT-BPLA ABPM Substudy & International Edema Discontinuation Registry (p < 0.001)',
          ),
          CompetitorComparisonDto(
            id: 'comp_crd_02',
            competitorName: 'Tamsulosin 0.4mg Monotherapy',
            theirClaim:
                'Tamsulosin is the uroselective benchmark for benign prostatic hyperplasia and avoids impacting systemic hemodynamics.',
            howToRespond:
                'For purely normotensive men, uroselectivity is appropriate; however, over 60% of BPH patients over age 55 suffer from co-existing hypertension. Treating with Tamsulosin plus an antihypertensive doubles the pill burden and copays. Cardura XL GITS manages both conditions effectively in a single daily morning dose.',
            proofReference:
                'European Urology Guideline Registry 2025: Co-morbidity in Aging Hypertensive Males',
          ),
          CompetitorComparisonDto(
            id: 'comp_crd_03',
            competitorName: 'Losartan / HCTZ Fixed Dose Combination',
            theirClaim:
                'ARB plus diuretic combination offers potent blood pressure reduction with well-established renal protection.',
            howToRespond:
                'Highlight metabolic neutrality: thiazide diuretics can cause hypokalemia, elevate uric acid, and exacerbate nighttime nocturia, which is especially disruptive for elderly males. Cardura XL avoids diuretic-induced nocturia while improving bladder emptying and maintaining electrolyte balance.',
            proofReference:
                'American Journal of Hypertension: Nocturia and Sleep Fragmentation in Hypertensive Cohorts',
          ),
        ],
        lessons: [
          LessonDto(
            id: 'les_crd_01',
            productId: 'prod_cardura_xl',
            productName: 'Cardura XL',
            title: 'Cardura XL GITS Delivery Mechanism & Absorption Kinetics',
            durationMinutes: 4,
            isCompleted: true,
            isBookmarked: true,
            order: 1,
            sections: [
              LessonSectionDto(
                title: 'The Osmotic Pump Principle',
                content:
                    'Cardura XL utilizes the Gastrointestinal Therapeutic System (GITS), an osmotic pressure-activated delivery mechanism. As water enters the semi-permeable membrane from the GI tract, an internal osmotic push compartment expands at a constant rate, releasing doxazosin through a laser-drilled orifice over 24 hours.',
                keyTakeaway:
                    'Zero peak-related hypotension and smooth continuous 24-hour plasma concentration.',
              ),
              LessonSectionDto(
                title: 'Elimination of First-Dose Syncope',
                content:
                    'Traditional immediate-release alpha-1 blockers were plagued by first-dose postural syncope due to rapid drug surges. With GITS technology, the maximum plasma concentration (Cmax) is tempered and delayed to 8-10 hours, completely eliminating first-dose collapse risk.',
                keyTakeaway:
                    'No mandatory bedtime first-dose titration required; safe for standard morning breakfast dosing.',
              ),
            ],
          ),
          LessonDto(
            id: 'les_crd_02',
            productId: 'prod_cardura_xl',
            productName: 'Cardura XL',
            title: 'Night-time Blood Pressure Dip & Early Morning Surge Protection',
            durationMinutes: 5,
            isCompleted: true,
            isBookmarked: false,
            order: 2,
            sections: [
              LessonSectionDto(
                title: 'Why Morning Surge Matters',
                content:
                    'The highest incidence of myocardial infarction and ischemic stroke occurs between 6:00 AM and 10:00 AM, coinciding with the physiological morning blood pressure surge. Standard short-acting antihypertensives lose therapeutic efficacy in hours 20 through 24.',
                keyTakeaway:
                    'Cardura XL maintains a trough-to-peak ratio > 78%, protecting patients during the critical dawn hazard window.',
              ),
            ],
          ),
          LessonDto(
            id: 'les_crd_03',
            productId: 'prod_cardura_xl',
            productName: 'Cardura XL',
            title: 'Dual Benefit Detailing: Hypertension with Concomitant BPH',
            durationMinutes: 6,
            isCompleted: true,
            isBookmarked: false,
            order: 3,
            sections: [
              LessonSectionDto(
                title: 'Targeting the Hypertensive Male Over 50',
                content:
                    'In clinical practice, reps often detail hypertension to cardiologists and BPH to urologists. The real clinical opportunity is cross-specialty positioning: 6 out of 10 hypertensive men over 50 experience lower urinary tract symptoms (hesitancy, weak stream, nocturia).',
                keyTakeaway:
                    'One tablet replaces two prescriptions, lowers annual healthcare copays, and improves therapy compliance.',
              ),
            ],
          ),
          LessonDto(
            id: 'les_crd_04',
            productId: 'prod_cardura_xl',
            productName: 'Cardura XL',
            title: 'Overcoming the Amlodipine Edema & Pricing Objection',
            durationMinutes: 4,
            isCompleted: false,
            isBookmarked: true,
            order: 4,
            sections: [
              LessonSectionDto(
                title: 'Handling the Commodity Stigma',
                content:
                    'When doctors say "amlodipine is 10 times cheaper", do not dispute price. Frame the discussion around total patient cost: amlodipine discontinuation due to bilateral ankle edema leads to extra clinic visits, lab tests, and loop diuretic prescriptions.',
                keyTakeaway:
                    'Validate efficacy first, contrast tolerability, and introduce company copay assistance cards.',
              ),
            ],
          ),
          LessonDto(
            id: 'les_crd_05',
            productId: 'prod_cardura_xl',
            productName: 'Cardura XL',
            title: 'Dosing, Titration Thresholds & Renal Safety Profile',
            durationMinutes: 3,
            isCompleted: false,
            isBookmarked: false,
            order: 5,
            sections: [
              LessonSectionDto(
                title: 'Simple Starting Regimen',
                content:
                    'Initiate at 4mg once daily. Assess clinical efficacy at 4 weeks. If daytime or ambulatory systolic targets require intensification, escalate to 8mg once daily. More than 70% of mild-to-moderate hypertensive patients achieve target BP on 4mg monotherapy.',
                keyTakeaway:
                    'No dose adjustments in renal impairment or elderly; safe across all stages of non-dialysis CKD.',
              ),
            ],
          ),
          LessonDto(
            id: 'les_crd_06',
            productId: 'prod_cardura_xl',
            productName: 'Cardura XL',
            title: 'Formulary Detailing & Pharmacy Co-pay Card Positioning',
            durationMinutes: 5,
            isCompleted: false,
            isBookmarked: false,
            order: 6,
            sections: [
              LessonSectionDto(
                title: 'Ensuring Script Fulfillment',
                content:
                    'A physician may be convinced by clinical data, but if the prescription triggers an insurance rejection at retail checkout, the patient leaves empty-handed. Equip the physician with digital co-pay enrollment QR codes.',
                keyTakeaway:
                    'Highlight Tier-1 co-pay coverage: eligible commercial insured patients pay as little as \$5/month.',
              ),
            ],
          ),
        ],
      ),

      // 2. AtorvaCare 20mg (Recommended, In-Progress: 2 of 5 completed)
      const ProductLearningDto(
        id: 'prod_atorvacare',
        name: 'AtorvaCare 20mg',
        therapeuticArea: 'Dyslipidemia & ASCVD',
        isRecommended: true,
        positioning: ProductPositioningDto(
          keyMessage:
              'Stabilized crystalline formulation engineered to provide predictable LDL-C reduction of 48% with minimized systemic muscle accumulation.',
          targetDoctors: [
            'Cardiologists managing post-ACS secondary prevention regimens',
            'Endocrinologists treating diabetic dyslipidemia with high ASCVD risk',
            'Internal medicine clinicians managing statin-hesitant patient cohorts',
          ],
          keyBenefits: [
            'Consistent 48% mean LDL-C reduction with significant ApoB and triglyceride lowering',
            'High hepatic extraction ratio (>70%) minimizing systemic muscle tissue exposure',
            'Once-daily dosing with or without food at any time of day',
            'Robust clinical evidence in acute coronary syndrome and diabetic renal cohorts',
          ],
          dosageHighlights: [
            'Standard adult starting dose: 20mg once daily',
            'Severe ASCVD or ACS post-discharge: Titrate to 40mg or 80mg based on guideline targets',
            'No renal dose adjustment required in patients with chronic kidney disease',
          ],
          proofPoints: [
            'SAMSON N-of-1 Clinical Trial: 90% of perceived muscle symptoms were nocebo-driven; 88% tolerated guided re-initiation',
            'MIRACL & PROVE-IT Studies: Early high-intensity initiation within 24-96h of ACS reduces recurrent ischemic events by 16%',
            'Renal Sub-analysis: Sustained eGFR trajectory over 36 months in diabetic cohorts',
          ],
        ),
        competitors: [
          CompetitorComparisonDto(
            id: 'comp_atg_01',
            competitorName: 'Rosuvastatin 10mg / 20mg',
            theirClaim:
                'Rosuvastatin provides marginally higher milligram-for-milligram LDL reduction and is hydrophilic.',
            howToRespond:
                'While Rosuvastatin is potent, AtorvaCare provides proven long-term ACS plaque regression data and has a significantly lower incidence of dose-dependent proteinuria in diabetic nephropathy patients.',
            proofReference:
                'PLANET I & II Clinical Trials: Comparative Renal Effects of Statin Therapy in Diabetic Proteinuria',
          ),
        ],
        lessons: [
          LessonDto(
            id: 'les_atg_01',
            productId: 'prod_atorvacare',
            productName: 'AtorvaCare 20mg',
            title: 'SAMS Management: Differentiating True Myopathy from Nocebo',
            durationMinutes: 5,
            isCompleted: true,
            isBookmarked: true,
            order: 1,
          ),
          LessonDto(
            id: 'les_atg_02',
            productId: 'prod_atorvacare',
            productName: 'AtorvaCare 20mg',
            title: 'ASCVD Secondary Prevention: Early Initiation Protocols',
            durationMinutes: 4,
            isCompleted: true,
            isBookmarked: false,
            order: 2,
          ),
          LessonDto(
            id: 'les_atg_03',
            productId: 'prod_atorvacare',
            productName: 'AtorvaCare 20mg',
            title: 'Overcoming the Rosuvastatin Potency Argument',
            durationMinutes: 4,
            isCompleted: false,
            isBookmarked: false,
            order: 3,
          ),
          LessonDto(
            id: 'les_atg_04',
            productId: 'prod_atorvacare',
            productName: 'AtorvaCare 20mg',
            title: 'Renal Safety in Diabetic Proteinuric Cohorts',
            durationMinutes: 3,
            isCompleted: false,
            isBookmarked: false,
            order: 4,
          ),
          LessonDto(
            id: 'les_atg_05',
            productId: 'prod_atorvacare',
            productName: 'AtorvaCare 20mg',
            title: 'Stepwise Re-challenge Protocol for Hesitant Patients',
            durationMinutes: 4,
            isCompleted: false,
            isBookmarked: false,
            order: 5,
          ),
        ],
      ),

      // 3. LipiShield Duo (In-Progress: 1 of 4 completed)
      const ProductLearningDto(
        id: 'prod_lipishield',
        name: 'LipiShield Duo',
        therapeuticArea: 'Dual Lipid Management',
        isRecommended: false,
        positioning: ProductPositioningDto(
          keyMessage:
              'Fixed-dose combination offering complementary dual inhibition: blocks intestinal cholesterol absorption while suppressing hepatic synthesis.',
          targetDoctors: [
            'Cardiologists and lipid specialists treating refractory high-risk hypercholesterolemia',
            'Endocrinologists aiming for LDL < 55 mg/dL in very-high-risk patients',
          ],
          keyBenefits: [
            'Achieves up to 65% LDL-C reduction without escalating to maximum statin doses',
            'Dual pathway inhibition (NPC1L1 + HMG-CoA reductase)',
            'Single daily tablet improves adherence compared to co-prescribing two distinct pills',
          ],
          dosageHighlights: [
            'One tablet daily (10mg/20mg) taken at any time with or without food',
            'No dosage titration required for the ezetimibe component',
          ],
          proofPoints: [
            'IMPROVE-IT Trial: Proven incremental cardiovascular event reduction when adding ezetimibe to statin monotherapy (HR 0.936, p=0.016)',
            'Goal Achievement Registry: 84% reached strict ESC/EAS 2025 LDL targets',
          ],
        ),
        competitors: [
          CompetitorComparisonDto(
            id: 'comp_lip_01',
            competitorName: 'High-Dose Statin Monotherapy (Atorvastatin 80mg)',
            theirClaim:
                'Titrating up to 80mg statin monotherapy is cheaper than fixed-dose combination therapy.',
            howToRespond:
                'Doubling a statin dose yields only ~6% additional LDL reduction (the rule of 6), while tripling liver enzyme and muscle toxicity risks. LipiShield Duo adds 20-25% incremental LDL reduction via a completely distinct pathway.',
            proofReference:
                'Circulation: The Rule of Sixes and Non-statin Add-on Comparative Meta-analysis',
          ),
        ],
        lessons: [
          LessonDto(
            id: 'les_lip_01',
            productId: 'prod_lipishield',
            productName: 'LipiShield Duo',
            title: 'Dual Pathway Pharmacology: Absorption vs Synthesis',
            durationMinutes: 4,
            isCompleted: true,
            isBookmarked: false,
            order: 1,
          ),
          LessonDto(
            id: 'les_lip_02',
            productId: 'prod_lipishield',
            productName: 'LipiShield Duo',
            title: 'The Rule of Sixes: Why High-Dose Titration Fails Patients',
            durationMinutes: 5,
            isCompleted: false,
            isBookmarked: true,
            order: 2,
          ),
          LessonDto(
            id: 'les_lip_03',
            productId: 'prod_lipishield',
            productName: 'LipiShield Duo',
            title: 'Reaching Extreme LDL Targets (< 55 mg/dL) in Post-MI Patients',
            durationMinutes: 4,
            isCompleted: false,
            isBookmarked: false,
            order: 3,
          ),
          LessonDto(
            id: 'les_lip_04',
            productId: 'prod_lipishield',
            productName: 'LipiShield Duo',
            title: 'Formulary Presentation for Pharmacy & Therapeutics Committees',
            durationMinutes: 4,
            isCompleted: false,
            isBookmarked: false,
            order: 4,
          ),
        ],
      ),

      // 4. CardioPulse XL (Unstarted: 0 of 5 completed)
      const ProductLearningDto(
        id: 'prod_cardiopulse',
        name: 'CardioPulse XL',
        therapeuticArea: 'Heart Failure & Arrhythmia',
        isRecommended: false,
        positioning: ProductPositioningDto(
          keyMessage:
              'Extended-release cardioprotective beta-1 selective blocker designed to stabilize heart rate variability and reduce 30-day hospital re-admissions.',
          targetDoctors: [
            'Heart failure specialists in tertiary referral cardiac centers',
            'Interventional cardiologists following up post-PCI patients',
          ],
          keyBenefits: [
            'Proven mortality and hospitalization reduction in HFrEF NYHA Class II-IV',
            'Superior beta-1 selectivity minimizing bronchospasm in COPD co-morbidities',
            'Smooth 24-hour hemodynamic profile avoiding bradycardic drops',
          ],
          dosageHighlights: [
            'Initial dose in stable HF: 25mg once daily',
            'Double dose every 2 weeks as tolerated to target maintenance dose of 200mg daily',
          ],
          proofPoints: [
            'MERIT-HF Trial: 34% reduction in all-cause mortality (p=0.0062) and 41% reduction in sudden death',
            'COPD Safety Sub-analysis: Zero clinically significant decline in FEV1 during long-term maintenance',
          ],
        ),
        competitors: [
          CompetitorComparisonDto(
            id: 'comp_cp_01',
            competitorName: 'Carvedilol 25mg BID',
            theirClaim:
                'Carvedilol provides dual alpha and beta blockade with vasodilatory advantages.',
            howToRespond:
                'Carvedilol requires strict twice-daily dosing with meals, leading to 35% non-compliance in real-world registries. It also induces postural dizziness and broncho-constriction due to non-selectivity. CardioPulse XL offers once-daily adherence and proven pulmonary safety.',
            proofReference:
                'Journal of the American College of Cardiology: Beta-Blocker Adherence in Heart Failure',
          ),
        ],
        lessons: [
          LessonDto(
            id: 'les_cp_01',
            productId: 'prod_cardiopulse',
            productName: 'CardioPulse XL',
            title: 'HFrEF Guideline-Directed Medical Therapy (GDMT) Overview',
            durationMinutes: 5,
            isCompleted: false,
            isBookmarked: false,
            order: 1,
          ),
          LessonDto(
            id: 'les_cp_02',
            productId: 'prod_cardiopulse',
            productName: 'CardioPulse XL',
            title: 'Beta-1 Selectivity vs Non-selective Agents in COPD Patients',
            durationMinutes: 4,
            isCompleted: false,
            isBookmarked: false,
            order: 2,
          ),
          LessonDto(
            id: 'les_cp_03',
            productId: 'prod_cardiopulse',
            productName: 'CardioPulse XL',
            title: 'The Carvedilol BID vs Once-Daily Adherence Argument',
            durationMinutes: 4,
            isCompleted: false,
            isBookmarked: false,
            order: 3,
          ),
          LessonDto(
            id: 'les_cp_04',
            productId: 'prod_cardiopulse',
            productName: 'CardioPulse XL',
            title: 'Titration Protocol & Managing Early Symptom Fluctuations',
            durationMinutes: 4,
            isCompleted: false,
            isBookmarked: false,
            order: 4,
          ),
          LessonDto(
            id: 'les_cp_05',
            productId: 'prod_cardiopulse',
            productName: 'CardioPulse XL',
            title: 'Hospital Discharge Detailing for 30-Day Re-admission Prevention',
            durationMinutes: 5,
            isCompleted: false,
            isBookmarked: false,
            order: 5,
          ),
        ],
      ),
    ];
  }
}
