import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/material_item_dto.dart';

/// Remote Datasource Contract for Resource Library
abstract class LibraryRemoteDatasource {
  Future<List<MaterialItemDto>> getMaterials();
}

/// Remote Datasource Implementation backed by GET /media/materials
class LibraryRemoteDatasourceImpl implements LibraryRemoteDatasource {
  final Dio? dio;
  final bool simulateError;

  LibraryRemoteDatasourceImpl({
    this.dio,
    this.simulateError = false,
  });

  @override
  Future<List<MaterialItemDto>> getMaterials() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve materials from enterprise server');
    }

    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.materials);
      final list = ApiResponseParser.unwrapList(response.data);
      final dtos = list.map(MaterialItemDto.fromJson).toList();
      return _normalizeEdetailingDecks(dtos);
    }

    // Fallback offline/test fixtures when Dio is not provided
    await Future<void>.delayed(const Duration(milliseconds: 50));

    return [
      // 1. Cardura XL Monograph (PDF)
      const MaterialItemDto(
        id: 'mat_crd_01',
        title: 'Cardura XL 4mg & 8mg Official Prescribing Monograph',
        productName: 'Cardura XL',
        category: 'brochure',
        fileType: 'pdf',
        fileSizeBytes: 3565158, // 3.4 MB
        updatedAt: '2026-11-04T10:00:00Z',
        badge: 'updated',
        isFavorite: true,
        isDownloaded: true,
        viewCount: 142,
        pageCount: 8,
        description:
            'Comprehensive clinical pharmacokinetics, GITS gastrointestinal delivery, dosing titration in elderly patients, and renal impairment safety.',
      ),

      // 2. AtorvaCare E-Detail Presentation (Slides)
      const MaterialItemDto(
        id: 'mat_atg_01',
        title: 'AtorvaCare SAMS Management Clinical Presentation',
        productName: 'AtorvaCare 20mg',
        category: 'edetail',
        fileType: 'edetail',
        fileSizeBytes: 13212057, // 12.6 MB
        updatedAt: '2026-11-07T14:30:00Z',
        badge: 'new',
        isFavorite: true,
        isDownloaded: false,
        viewCount: 89,
        pageCount: 6,
        description:
            'Interactive physician detailing deck addressing Statin-Associated Muscle Symptoms (SAMS), differential diagnosis, and co-enzyme Q10 co-administration evidence.',
        slides: [
          MaterialSlideDto(
            slideNumber: 1,
            title: 'Epidemiology of Statin Adherence',
            headline: 'Over 50% of high-risk ASCVD patients discontinue statins within year 1',
            clinicalKeyPoints: [
              'Subjective muscle ache is the #1 cited rationale for non-compliance.',
              'True myopathy incidence remains < 0.1%, but perceived intolerance leads to early abandonment.',
            ],
            bulletEvidence: [
              'PRIMO Study (n=7,924): 10.5% reported muscle discomfort on older high-lipophilic statins.',
              'AtorvaCare stabilized crystalline formulation reduces tissue accumulation variance.',
            ],
            chartCaption: 'Figure 1: Real-world discontinuation curves over 24 months (N=14,200)',
          ),
          MaterialSlideDto(
            slideNumber: 2,
            title: 'Pharmacokinetic Differentiation',
            headline: 'Targeted hepatic selectivity minimizes systemic systemic muscle exposure',
            clinicalKeyPoints: [
              'High hepatic extraction ratio (>70%) ensures concentrated HMG-CoA reductase inhibition.',
              'Elimination half-life of 14 hours provides sustained 24-hour LDL-C suppression.',
            ],
            bulletEvidence: [
              'Minimal cytochrome P450 3A4 competitive displacement when paired with common ACE inhibitors.',
              'Proven steady-state bioavailability without mandatory food timing requirements.',
            ],
            chartCaption: 'Figure 2: Comparative plasma area-under-curve (AUC) profile in healthy volunteers',
          ),
          MaterialSlideDto(
            slideNumber: 3,
            title: 'Double-Blind Re-challenge Protocol',
            headline: 'Rigorous N-of-1 trial confirms 88% tolerance on guided re-introduction',
            clinicalKeyPoints: [
              'Stepwise re-initiation strategy preserves CV risk reduction in 9 out of 10 hesitant patients.',
              'Recommend alternate-day dosing transition before total discontinuation.',
            ],
            bulletEvidence: [
              'SAMSON Trial analysis: 90% of symptom burden during statin intake was nocebo-driven.',
              'Empowers clinicians with evidence-backed reassurance scripts.',
            ],
            chartCaption: 'Figure 3: Placebo vs AtorvaCare symptom intensity scores (p=0.002)',
          ),
          MaterialSlideDto(
            slideNumber: 4,
            title: 'Renal Safety Sub-analysis',
            headline: 'Zero dose adjustment required across CKD Stages 1 through 4',
            clinicalKeyPoints: [
              'Renal clearance accounts for less than 2% of systemic elimination.',
              'Ideal first-choice option for diabetic nephropathy co-morbidities.',
            ],
            bulletEvidence: [
              'No significant elevation in serum creatinine or eGFR degradation over 36 months.',
              'Cardioprotective microalbuminuria reduction demonstrated in landmark renal substudy.',
            ],
            chartCaption: 'Figure 4: eGFR stability trajectory over 3 years in hypertensive diabetics',
          ),
          MaterialSlideDto(
            slideNumber: 5,
            title: 'Formulary & Co-pay Positioning',
            headline: 'Tier-1 commercial insurance status across 94% of regional healthcare plans',
            clinicalKeyPoints: [
              'Average out-of-pocket cost is \$0 to \$10 per month with co-pay card.',
              'Available at all major hospital outpatient and retail chain pharmacies nationwide.',
            ],
            bulletEvidence: [
              'Automatic electronic prior authorization (ePA) integrated into leading EMR systems.',
              'Dedicated nurse navigation patient assistance program for uninsured populations.',
            ],
            chartCaption: 'Coverage Map: 2026 regional HMO/PPO formulary inclusion tiers',
          ),
          MaterialSlideDto(
            slideNumber: 6,
            title: 'Summary & Call to Action',
            headline: 'Preserve cardioprotection: initiate or transition your patients today',
            clinicalKeyPoints: [
              'Review current ASCVD risk and baseline lipid panel.',
              'Prescribe AtorvaCare 20mg once daily at bedtime.',
              'Provide patient SAMS reassurance booklet available in clinic brochure rack.',
            ],
            bulletEvidence: [
              'Sample packs (7-day blister kits) available for immediate in-office transition.',
              'Follow-up lipid re-check suggested at 6 to 8 weeks post-initiation.',
            ],
            chartCaption: 'Dosing Guidance: Starting dose titration schedule',
          ),
        ],
      ),

      // 3. LipiShield Duo Visual Aid (Image)
      const MaterialItemDto(
        id: 'mat_lip_01',
        title: 'LipiShield Duo Dual-Mechanism Absorption & Synthesis Chart',
        productName: 'LipiShield Duo',
        category: 'visual_aid',
        fileType: 'image',
        fileSizeBytes: 1887436, // 1.8 MB
        updatedAt: '2026-10-28T09:15:00Z',
        badge: 'none',
        isFavorite: false,
        isDownloaded: true,
        viewCount: 63,
        pageCount: 1,
        description:
            'High-resolution clinical diagram demonstrating complementary dual inhibition: NPC1L1 cholesterol absorption inhibition + hepatic HMG-CoA synthesis suppression.',
      ),

      // 4. Cardura XL Ambulatory Blood Pressure Chart (Image)
      const MaterialItemDto(
        id: 'mat_crd_02',
        title: 'Cardura XL 24-Hour Ambulatory Blood Pressure Profile',
        productName: 'Cardura XL',
        category: 'visual_aid',
        fileType: 'image',
        fileSizeBytes: 2306867, // 2.2 MB
        updatedAt: '2026-11-02T16:00:00Z',
        badge: 'updated',
        isFavorite: false,
        isDownloaded: false,
        viewCount: 110,
        pageCount: 1,
        description:
            'Continuous ABPM clinical curve proving night-time dip restoration and absence of early morning systolic blood pressure surge.',
      ),

      // 5. CardioPulse XL Physician Summary Dossier (PDF)
      const MaterialItemDto(
        id: 'mat_cp_01',
        title: 'CardioPulse XL Hospital Formulary Submission Dossier',
        productName: 'CardioPulse XL',
        category: 'brochure',
        fileType: 'pdf',
        fileSizeBytes: 4299161, // 4.1 MB
        updatedAt: '2026-10-15T11:20:00Z',
        badge: 'none',
        isFavorite: false,
        isDownloaded: false,
        viewCount: 38,
        pageCount: 12,
        description:
            'Economic value dossier, budget impact modeling, and 30-day hospital re-admission reduction statistics for cardiology P&T committees.',
      ),

      // 6. AtorvaCare Renal Outcomes Slide Deck (Slides)
      const MaterialItemDto(
        id: 'mat_atg_02',
        title: 'AtorvaCare Phase IV Renal Outcomes Slide Deck',
        productName: 'AtorvaCare 20mg',
        category: 'edetail',
        fileType: 'edetail',
        fileSizeBytes: 17196646, // 16.4 MB
        updatedAt: '2026-11-08T08:00:00Z',
        badge: 'new',
        isFavorite: false,
        isDownloaded: false,
        viewCount: 74,
        pageCount: 8,
        description:
            'Key opinion leader detailing deck on 5-year renal microvascular preservation in diabetic hypertensive cohorts.',
      ),

      // 7. LipiShield Duo Co-Pay & Starter Kit (Marketing)
      const MaterialItemDto(
        id: 'mat_lip_02',
        title: 'LipiShield Duo Patient Starter Kit & Co-pay Card Program',
        productName: 'LipiShield Duo',
        category: 'marketing',
        fileType: 'pdf',
        fileSizeBytes: 972800, // 950 KB
        updatedAt: '2026-09-20T12:00:00Z',
        badge: 'none',
        isFavorite: false,
        isDownloaded: true,
        viewCount: 95,
        pageCount: 4,
        description:
            'Patient enrollment vouchers, zero-dollar copay eligibility guidelines, and clinic brochure rack replenishment request forms.',
      ),

      // 8. Cardura XL vs Amlodipine Dual BPH Monograph (Brochure)
      const MaterialItemDto(
        id: 'mat_crd_03',
        title: 'Cardura XL vs Amlodipine: Hemodynamic & Urological Outcomes',
        productName: 'Cardura XL',
        category: 'brochure',
        fileType: 'pdf',
        fileSizeBytes: 5452595, // 5.2 MB
        updatedAt: '2026-11-01T15:00:00Z',
        badge: 'updated',
        isFavorite: true,
        isDownloaded: false,
        viewCount: 168,
        pageCount: 10,
        description:
            'Comparative head-to-head clinical trial data demonstrating dual efficacy in male hypertensive patients with concomitant lower urinary tract symptoms (LUTS/BPH).',
      ),
    ];
  }

  /// Groups slide-level `e_detailing` rows for the same product into a single
  /// interactive presentation when `slides` are not already nested.
  List<MaterialItemDto> _normalizeEdetailingDecks(List<MaterialItemDto> items) {
    final result = <MaterialItemDto>[];
    final groupedDecks = <String, List<MaterialItemDto>>{};

    for (final item in items) {
      if (item.fileType == 'edetail' && item.slides.isEmpty) {
        final key = item.productName.isNotEmpty ? item.productName : item.id;
        groupedDecks.putIfAbsent(key, () => []).add(item);
      } else {
        result.add(item);
      }
    }

    for (final deckItems in groupedDecks.values) {
      deckItems.sort((a, b) => (a.slideOrder ?? 1).compareTo(b.slideOrder ?? 1));
      final first = deckItems.first;
      final slides = <MaterialSlideDto>[
        for (var i = 0; i < deckItems.length; i++)
          MaterialSlideDto(
            slideNumber: deckItems[i].slideOrder ?? (i + 1),
            title: deckItems[i].title,
            headline: deckItems[i].description.isNotEmpty
                ? deckItems[i].description
                : deckItems[i].title,
            clinicalKeyPoints: deckItems[i].description.isNotEmpty
                ? [deckItems[i].description]
                : const [],
            bulletEvidence: const [],
            imageUrl: deckItems[i].fileUrl,
          ),
      ];

      result.add(
        MaterialItemDto(
          id: first.id,
          title: first.title,
          productName: first.productName,
          category: first.category,
          fileType: first.fileType,
          fileSizeBytes: deckItems.fold<int>(0, (sum, e) => sum + e.fileSizeBytes),
          updatedAt: first.updatedAt,
          badge: first.badge,
          isFavorite: first.isFavorite,
          isDownloaded: first.isDownloaded,
          viewCount: first.viewCount,
          description: first.description,
          pageCount: slides.length,
          slides: slides,
          fileUrl: first.fileUrl,
          thumbnailUrl: first.thumbnailUrl ?? first.fileUrl,
          slideOrder: first.slideOrder,
        ),
      );
    }

    return result;
  }
}
