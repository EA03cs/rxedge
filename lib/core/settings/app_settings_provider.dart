import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_endpoints.dart';
import '../network/api_response.dart';
import '../network/dio_client.dart';
import 'app_settings_model.dart';

/// Provider for Centralized App Settings (`GET /app-settings`).
final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final dio = ref.watch(dioClientProvider);
  try {
    final response = await dio.get<dynamic>(ApiEndpoints.appSettings);
    final map = ApiResponseParser.unwrapMap(response.data);
    return AppSettings.fromJson(map);
  } catch (_) {
    // Graceful offline fallback
    return const AppSettings();
  }
});
