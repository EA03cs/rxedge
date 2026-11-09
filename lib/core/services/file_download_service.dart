import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import 'logger_service.dart';

/// Progress callback reporting received and total bytes
typedef DownloadProgressCallback = void Function(int received, int total);

/// Service for downloading clinical studies, product monographs, and detailing decks
class FileDownloadService {
  final Dio _dio;

  FileDownloadService(this._dio);

  Future<String> downloadFile({
    required String fileUrl,
    required String savePath,
    DownloadProgressCallback? onProgress,
  }) async {
    try {
      AppLogger.i('Starting file download: $fileUrl -> $savePath');
      await _dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: onProgress,
      );
      AppLogger.i('Download completed: $savePath');
      return savePath;
    } catch (e, st) {
      AppLogger.e('Download failed for: $fileUrl', error: e, stackTrace: st);
      rethrow;
    }
  }
}

final fileDownloadServiceProvider = Provider<FileDownloadService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FileDownloadService(dio);
});
