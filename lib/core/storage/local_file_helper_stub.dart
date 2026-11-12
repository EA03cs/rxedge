import 'package:flutter/widgets.dart';

/// Web/fallback implementation for local filesystem attachment helpers.
Future<String?> savePendingUploadBytes(List<int> bytes, String filename) async =>
    null;

Future<String?> createRecordingFilePath() async => null;

Future<List<int>?> readLocalFileBytes(String path) async => null;

bool localFileExists(String? path) => false;

Future<void> deleteLocalFile(String? path) async {}

Widget buildLocalFileImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function()? errorBuilder,
}) {
  return errorBuilder?.call() ?? const SizedBox.shrink();
}
