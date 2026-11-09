import '../../../../core/utils/result.dart';
import '../entities/app_info_entity.dart';
import '../repositories/app_info_repository.dart';

/// Usecase for retrieving application info metadata
class GetAppInfoUseCase {
  final AppInfoRepository _repository;

  const GetAppInfoUseCase(this._repository);

  Future<Result<AppInfoEntity>> call({bool forceRefresh = false}) {
    return _repository.getAppInfo(forceRefresh: forceRefresh);
  }
}
