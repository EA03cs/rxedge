import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/learning_dto.dart';
import 'rohto_seed_data.dart';

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

      // Always merge enriched lessons from GET /learn/lessons (contains title, userProgress with isCompleted, isBookmarked)
      final fullLessons = lessonsByProduct[pid];
      if (fullLessons != null && fullLessons.isNotEmpty) {
        prodMap['lessons'] = fullLessons;
      } else {
        final prodName = (prodMap['name']?.toString() ?? '').toLowerCase();
        final seedMatch = RohtoSeedData.products
            .where((p) => p.id == pid || p.name.toLowerCase() == prodName)
            .firstOrNull;
        if (seedMatch != null && seedMatch.lessons.isNotEmpty) {
          prodMap['lessons'] = seedMatch.lessons.map((l) => l.toJson()).toList();
        } else {
          prodMap['lessons'] = const <Map<String, dynamic>>[];
        }
      }

      final fullCompetitors = competitorsByProduct[pid];
      if (fullCompetitors != null && fullCompetitors.isNotEmpty) {
        prodMap['competitors'] = fullCompetitors;
      } else if (prodMap['competitors'] == null) {
        prodMap['competitors'] = const <Map<String, dynamic>>[];
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
