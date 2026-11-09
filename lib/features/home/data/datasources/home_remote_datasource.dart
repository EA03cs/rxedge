import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/home_dashboard_dto.dart';

/// Remote Datasource Contract for Home Dashboard
abstract class HomeRemoteDatasource {
  Future<HomeDashboardDto> getHomeDashboard();
}

/// Remote Datasource Implementation
/// Provides realistic clinical detailing mock data with support for live endpoint integration
class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final Dio? dio;
  final bool _simulateError;
  final bool _emptyContinueLesson;

  HomeRemoteDatasourceImpl({
    this.dio,
    bool simulateError = false,
    bool emptyContinueLesson = false,
  })  : _simulateError = simulateError,
        _emptyContinueLesson = emptyContinueLesson;

  @override
  Future<HomeDashboardDto> getHomeDashboard() async {
    if (_simulateError) {
      throw const ServerException('Failed to load dashboard data from remote server');
    }

    // When live backend is ready, this will perform:
    // final response = await _dio?.get(ApiEndpoints.homeDashboard);
    // For now, return realistic pharmaceutical mock data
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return HomeDashboardDto(
      continueLesson: _emptyContinueLesson
          ? null
          : const ContinueLearningDto(
              id: 'les_cardio_204',
              productName: 'AtorvaCare 20mg',
              lessonTitle: 'Managing Statin-Associated Muscle Symptoms (SAMS)',
              progress: 0.65,
              totalModules: 4,
              completedModules: 2,
            ),
      recommendedProduct: const RecommendedProductDto(
        id: 'prod_cardura_xl',
        productName: 'Cardura XL',
        therapeuticArea: 'Hypertension & BPH',
        description:
            'Gastrointestinal therapeutic system (GITS) providing 24h sustained blood pressure control.',
      ),
      challenge: const MonthlyChallengeDto(
        id: 'chal_nov_q4',
        title: 'Cardiovascular Knowledge Blitz',
        daysLeft: 4,
        progress: 0.72,
        currentRank: 3,
        totalParticipants: 28,
      ),
      objection: const DoctorObjectionDto(
        id: 'obj_vance_01',
        doctorQuote:
            '“I usually stick with generic amlodipine for stage 1 hypertension. Why switch patients to Cardura XL?”',
        doctorName: 'Dr. Robert Vance',
        specialty: 'Consultant Cardiologist, St. Jude Medical Center',
        productConcerned: 'Cardura XL',
        responseSummary:
            'Highlight 24-hour plasma concentration stability and dual efficacy in co-morbid BPH patients without dose titration risks.',
      ),
      recentMaterials: [
        MaterialUpdateDto(
          id: 'mat_01',
          title: 'AtorvaCare Phase IV Renal Safety Sub-study',
          specialty: 'Cardiology',
          badgeType: 'new',
          updatedAt: DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
        ),
        MaterialUpdateDto(
          id: 'mat_02',
          title: 'Cardura XL 2026 Dosing & Titration Monograph',
          specialty: 'Internal Medicine',
          badgeType: 'updated',
          updatedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        ),
        MaterialUpdateDto(
          id: 'mat_03',
          title: 'LipiShield Duo Comparative Bioequivalence Summary',
          specialty: 'Endocrinology',
          badgeType: 'new',
          updatedAt: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        ),
      ],
      stats: const RepStatsDto(
        points: 350,
        streakDays: 7,
        quizzesCompleted: 18,
      ),
    );
  }
}
