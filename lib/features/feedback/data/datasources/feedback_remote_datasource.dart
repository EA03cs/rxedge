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
  final Dio? dio;
  final bool simulateError;

  FeedbackRemoteDatasourceImpl({
    this.dio,
    this.simulateError = false,
  });

  @override
  Future<List<FeedbackItemDto>> getSubmissions() async {
    if (simulateError) {
      throw const ServerException('Failed to retrieve marketing feedback submissions');
    }

    if (dio != null) {
      final response = await dio!.get<dynamic>(ApiEndpoints.myFeedbackSubmissions);
      final list = ApiResponseParser.unwrapList(response.data);
      return list.map(FeedbackItemDto.fromJson).toList();
    }

    await Future<void>.delayed(const Duration(milliseconds: 140));

    return [
      // 1. Answered by Marketing
      FeedbackItemDto(
        id: 'fb_ans_01',
        typeString: 'doctorObjection',
        title: 'Cardura XL vs Generic Amlodipine Dosing Concern',
        submittedAtIso: DateTime.now().subtract(const Duration(days: 2, hours: 3)).toIso8601String(),
        statusString: 'answered',
        product: 'Cardura XL',
        objection:
            'Dr. Vance argued that doxazosin causes severe early-morning orthostatic hypotension compared to familiar amlodipine.',
        doctorSpecialty: 'Consultant Interventional Cardiologist',
        howResponded:
            'Clarified that GITS zero-order delivery eliminates the morning peak-to-trough spikes seen with generic alpha-blockers.',
        marketingReply:
            '“Excellent detailing response Alex! We are adding an explicit ABPM 24h nocturnal dipping slide into the deck next Monday to help all reps counter this amlodipine myth. Kudos for flagging.”',
        repliedBy: 'Dr. Kareem - Medical Affairs Director',
        repliedAtIso: DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
      ),

      // 2. Seen by Marketing
      FeedbackItemDto(
        id: 'fb_seen_02',
        typeString: 'competitorClaim',
        title: 'Competitor rep claiming bio-equivalence without published trial data',
        submittedAtIso: DateTime.now().subtract(const Duration(days: 1, hours: 5)).toIso8601String(),
        statusString: 'seen',
        competitorName: 'Generic Atorvastatin 40mg (PharmaStar)',
        claim:
            'Competitor reps are distributing unverified flyers claiming identical efficacy to AtorvaCare with zero active pharmaceutical ingredient differences.',
        whereHeard: 'Cardiology Department Head Meeting at Heliopolis University Hospital',
        photoUrl: 'assets/mock/flyer_sample.jpg',
      ),

      // 3. Sent
      FeedbackItemDto(
        id: 'fb_sent_03',
        typeString: 'fieldFeedback',
        title: 'Request for laminated GITS mechanism pocket guide',
        submittedAtIso: DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        statusString: 'sent',
        topic: 'Promotional Materials',
        details:
            'Several junior physicians requested a laminated pocket-sized GITS absorption curve card to keep on their clipboards during hospital rounds.',
      ),
    ];
  }

  @override
  Future<FeedbackItemDto> submitFeedback(FeedbackItemDto item) async {
    if (simulateError) {
      throw const NetworkException('Unable to reach marketing server');
    }

    if (dio != null) {
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
      final response = await dio!.post<dynamic>(
        ApiEndpoints.feedback,
        data: payload,
      );
      final map = ApiResponseParser.unwrapMap(response.data);
      return FeedbackItemDto.fromJson(map);
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));

    return FeedbackItemDto(
      id: item.id.isNotEmpty ? item.id : 'fb_${DateTime.now().millisecondsSinceEpoch}',
      typeString: item.typeString,
      title: item.title,
      submittedAtIso: DateTime.now().toIso8601String(),
      statusString: 'sent',
      product: item.product,
      objection: item.objection,
      doctorSpecialty: item.doctorSpecialty,
      howResponded: item.howResponded,
      competitorName: item.competitorName,
      claim: item.claim,
      whereHeard: item.whereHeard,
      photoUrl: item.photoUrl,
      topic: item.topic,
      details: item.details,
      voiceNoteUrl: item.voiceNoteUrl,
    );
  }

  @override
  Future<String> uploadAttachment({
    required List<int> bytes,
    required String filename,
  }) async {
    if (simulateError) {
      throw const NetworkException('Unable to upload attachment');
    }

    if (dio != null) {
      final formData = FormData.fromMap(<String, dynamic>{
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'subfolder': 'feedback',
      });
      final response = await dio!.post<dynamic>(
        ApiEndpoints.mediaUpload,
        data: formData,
      );
      final map = ApiResponseParser.unwrapMap(response.data);
      final rawUrl = map['url'] as String? ?? '';
      final resolved = UrlResolver.resolve(
        rawUrl,
        apiBaseUrl: dio!.options.baseUrl,
      );
      if (resolved == null || resolved.isEmpty) {
        throw const ServerException('Upload succeeded without returning file URL');
      }
      return resolved;
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    return 'http://localhost:4010/uploads/feedback/$filename';
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
