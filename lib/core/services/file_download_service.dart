import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../network/dio_client.dart';
import '../network/url_resolver.dart';
import 'logger_service.dart';

/// Progress callback reporting downloaded bytes vs total bytes
typedef DownloadProgressCallback = void Function(int received, int total);

/// Service for downloading large PDF brochures, E-Detailers, and clinical media
/// for offline viewing via `Dio.download` into local application storage.
class FileDownloadService {
  final Dio _dio;

  FileDownloadService(this._dio);

  /// Downloads [fileUrl] to [savePath] (or automatically chooses an app cache
  /// file path when only [savePath] filename is given) reporting progress.
  Future<String> downloadFile({
    required String fileUrl,
    required String savePath,
    DownloadProgressCallback? onProgress,
  }) async {
    final resolvedUrl = UrlResolver.resolve(fileUrl) ?? fileUrl;
    AppLogger.d('Starting download from $resolvedUrl -> $savePath');

    if (kIsWeb) {
      // On Flutter Web there is no local filesystem path for Dio.download;
      // pre-fetch bytes so browser HTTP cache stores the asset for offline use.
      await _dio.get<List<int>>(
        resolvedUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );
      return resolvedUrl;
    }

    var targetPath = savePath;
    if (!targetPath.contains('/') && !targetPath.contains('\\')) {
      final dir = await getApplicationDocumentsDirectory();
      targetPath = '${dir.path}/rxedge_downloads/$targetPath';
    }

    await _dio.download(
      resolvedUrl,
      targetPath,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received, total);
        }
      },
    );

    AppLogger.i('Successfully downloaded file to: $targetPath');
    return targetPath;
  }

  /// Resolves the destination path under the app documents directory for a material ID.
  Future<String> resolveLocalMaterialPath(String materialId, {String ext = 'bin'}) async {
    if (kIsWeb) return 'web_cached_$materialId.$ext';
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/rxedge_downloads/$materialId.$ext';
  }
}

final fileDownloadServiceProvider = Provider<FileDownloadService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FileDownloadService(dio);
});
