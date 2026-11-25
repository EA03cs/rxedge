import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/url_resolver.dart';
import '../../../../core/storage/local_file_helper.dart';
import '../models/feedback_dto.dart';

/// Remote Datasource Contract for Live Marketing Feedback
abstract class FeedbackRemoteDatasource {
  Future<List<FeedbackItemDto>> getSubmissions();
  Future<FeedbackItemDto> submitFeedback(FeedbackItemDto item);
  Future<String> uploadAttachment({
    required List<int> bytes,
    required String filename,
  });
}

/// Remote Datasource Implementation backed by `/feedback` and `/feedback/my-submissions`
class FeedbackRemoteDatasourceImpl implements FeedbackRemoteDatasource {
  final Dio dio;
  final bool simulateError;

  FeedbackRemoteDatasourceImpl({
    required this.dio,
    this.simulateError = false,
  });

  @override
  Future<List<FeedbackItemDto>> getSubmissions() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve marketing feedback submissions');
    }

    final response = await dio.get<dynamic>(ApiEndpoints.myFeedbackSubmissions);
    final list = ApiResponseParser.unwrapList(response.data);
    return list.map(FeedbackItemDto.fromJson).toList();
  }

  @override
  Future<FeedbackItemDto> submitFeedback(FeedbackItemDto item) async {
    if (simulateError) {
      throw const NetworkException('Unable to reach marketing server');
    }

    final payload = item.toBackendPayload();
    await _uploadLocalPathIfNeeded(
      payload: payload,
      fieldKey: 'attachmentUrl',
      localPath: item.photoUrl,
      fallbackFilename: 'feedback_photo.jpg',
    );
    await _uploadLocalPathIfNeeded(
      payload: payload,
      fieldKey: 'voiceNoteUrl',
      localPath: item.voiceNoteUrl,
      fallbackFilename: 'voice_note.m4a',
    );
    final response = await dio.post<dynamic>(
      ApiEndpoints.feedback,
      data: payload,
    );
    final map = ApiResponseParser.unwrapMap(response.data);
    return FeedbackItemDto.fromJson(map);
  }

  @override
  Future<String> uploadAttachment({
    required List<int> bytes,
    required String filename,
  }) async {
    if (simulateError) {
      throw const NetworkException('Unable to upload attachment');
    }

    final formData = FormData.fromMap(<String, dynamic>{
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'subfolder': 'feedback',
    });
    final response = await dio.post<dynamic>(
      ApiEndpoints.mediaUpload,
      data: formData,
    );
    final map = ApiResponseParser.unwrapMap(response.data);
    final rawUrl = map['url']?.toString() ?? '';
    final resolved = UrlResolver.resolve(
      rawUrl,
      apiBaseUrl: dio.options.baseUrl,
    );
    if (resolved == null || resolved.isEmpty) {
      throw const ServerException('Upload succeeded without returning file URL');
    }
    return resolved;
  }

  Future<void> _uploadLocalPathIfNeeded({
    required Map<String, dynamic> payload,
    required String fieldKey,
    required String? localPath,
    required String fallbackFilename,
  }) async {
    if (payload[fieldKey] != null ||
        localPath == null ||
        !localFileExists(localPath)) {
      return;
    }
    final bytes = await readLocalFileBytes(localPath);
    if (bytes == null || bytes.isEmpty) return;
    final filename = localPath.split(RegExp(r'[/\\]')).last;
    final uploadedUrl = await uploadAttachment(
      bytes: bytes,
      filename: filename.isEmpty ? fallbackFilename : filename,
    );
    payload[fieldKey] = uploadedUrl;
    await deleteLocalFile(localPath);
  }
}
