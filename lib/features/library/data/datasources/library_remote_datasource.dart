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
  final Dio dio;
  final bool simulateError;

  LibraryRemoteDatasourceImpl({
    required this.dio,
    this.simulateError = false,
  });

  @override
  Future<List<MaterialItemDto>> getMaterials() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve materials from enterprise server');
    }

    final response = await dio.get<dynamic>(ApiEndpoints.materials);
    final list = ApiResponseParser.unwrapList(response.data);
    final dtos = list.map(MaterialItemDto.fromJson).toList();
    return _normalizeEdetailingDecks(dtos);
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
