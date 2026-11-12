import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/learning_dto.dart';

/// Remote Datasource Contract for Learn
abstract class LearnRemoteDatasource {
  Future<List<ProductLearningDto>> getProducts();
  Future<void> completeLesson(String lessonId);
  Future<void> bookmarkLesson(String lessonId);
}

/// Real REST implementation querying `GET /products`, `GET /learn/lessons`,
/// `GET /competitors`, `POST /learn/lessons/:id/complete`, and `POST /learn/lessons/:id/bookmark`.
class LearnRemoteDatasourceImpl implements LearnRemoteDatasource {
  final Dio _dio;

  LearnRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ProductLearningDto>> getProducts() async {
    final results = await Future.wait([
      _dio.get<dynamic>(ApiEndpoints.products),
      _dio.get<dynamic>(ApiEndpoints.learnLessons),
      _dio.get<dynamic>(ApiEndpoints.competitors),
    ]);

    final rawProducts = ApiResponseParser.unwrapList(results[0].data);
    final rawLessons = ApiResponseParser.unwrapList(results[1].data);
    final rawCompetitors = ApiResponseParser.unwrapList(results[2].data);

    final lessonsByProduct = <String, List<Map<String, dynamic>>>{};
    for (final lesson in rawLessons) {
      final pid = lesson['productId']?.toString() ?? '';
      lessonsByProduct.putIfAbsent(pid, () => []).add(lesson);
    }

    final competitorsByProduct = <String, List<Map<String, dynamic>>>{};
    for (final comp in rawCompetitors) {
      final pid = comp['productId']?.toString() ?? '';
      competitorsByProduct.putIfAbsent(pid, () => []).add(comp);
    }

    final dtos = <ProductLearningDto>[];
    for (var i = 0; i < rawProducts.length; i++) {
      final prodMap = Map<String, dynamic>.from(rawProducts[i]);
      final pid = prodMap['id']?.toString() ?? '';

      if (prodMap['lessons'] == null || (prodMap['lessons'] as List).isEmpty) {
        prodMap['lessons'] = lessonsByProduct[pid] ?? const [];
      }
      if (prodMap['competitors'] == null ||
          (prodMap['competitors'] as List).isEmpty) {
        prodMap['competitors'] = competitorsByProduct[pid] ?? const [];
      }
      if (prodMap['isRecommended'] == null && prodMap['is_recommended'] == null) {
        prodMap['isRecommended'] = i == 0;
      }

      dtos.add(ProductLearningDto.fromJson(prodMap));
    }

    return dtos;
  }

  @override
  Future<void> completeLesson(String lessonId) async {
    await _dio.post<dynamic>(ApiEndpoints.completeLesson(lessonId));
  }

  @override
  Future<void> bookmarkLesson(String lessonId) async {
    await _dio.post<dynamic>(ApiEndpoints.bookmarkLesson(lessonId));
  }
}
