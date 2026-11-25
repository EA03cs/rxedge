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
      // 1. Rohto Dry Aid Brochure (Google Drive)
      const MaterialItemDto(
        id: 'mat_rohto_dry_aid_01',
        title: 'Rohto Dry Aid Brochure',
        productName: 'Rohto Dry Aid',
        category: 'brochure',
        fileType: 'pdf',
        fileSizeBytes: 1258291, // 1.2 MB
        updatedAt: '2026-11-19T12:00:00Z',
        badge: 'new',
        isFavorite: false,
        isDownloaded: false,
        viewCount: 210,
        pageCount: 10,
        thumbnailUrl: 'assets/images/rohto_dry_aid.png',
        fileUrl:
            'https://drive.google.com/file/d/1jaenvaltpOhA0x82DN2OHV39twZn9ms-/view?usp=drive_link',
        description:
            'Rohto Dry Aid Tearshield Technology brochure covering 3-layer tear film restoration and 12-hour relief.',
      ),

      // 2. Rohto Cool Brochure (Google Drive)
      const MaterialItemDto(
        id: 'mat_rohto_cool_01',
        title: 'Rohto Cool Brochure',
        productName: 'Rohto Cool',
        category: 'brochure',
        fileType: 'pdf',
        fileSizeBytes: 979968, // ~957 KB
        updatedAt: '2026-11-19T11:00:00Z',
        badge: 'new',
        isFavorite: false,
        isDownloaded: false,
        viewCount: 180,
        pageCount: 8,
        thumbnailUrl: 'assets/images/rohto_cool.png',
        fileUrl:
            'https://drive.google.com/file/d/1MYbkjhlgiovvJe7AE_XIGPVhg2YlZZ9l/view?usp=sharing',
        description:
            'Rohto Cool refreshing hydration brochure for contact lens wearers and digital eye strain.',
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
