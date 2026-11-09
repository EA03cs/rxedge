import '../../../../core/utils/result.dart';
import '../entities/app_info_entity.dart';

/// Abstract Domain Repository Contract
///
/// Follows Clean Architecture Dependency Rule:
/// "presentation -> domain <- data. Domain has zero Flutter/Dio/Hive imports."
abstract class AppInfoRepository {
  Future<Result<AppInfoEntity>> getAppInfo({bool forceRefresh = false});
}
