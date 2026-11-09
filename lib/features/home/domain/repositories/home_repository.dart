import '../../../../core/utils/result.dart';
import '../entities/home_dashboard_entity.dart';

/// Abstract Home Repository Contract
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."
abstract class HomeRepository {
  Future<Result<HomeDashboardEntity>> getHomeDashboard({bool forceRefresh = false});
}
