import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// Saves pending upload bytes into app documents directory so offline-queued
/// items can upload reliably even after temporary OS picker caches are cleared.
Future<String?> savePendingUploadBytes(List<int> bytes, String filename) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/rxedge_pending_uploads');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final safeName = filename.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final target = File(
      '${folder.path}/${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  } catch (_) {
    return null;
  }
}

/// Allocates a file path inside app documents directory for voice recording.
Future<String?> createRecordingFilePath() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/rxedge_pending_uploads');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return '${folder.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
  } catch (_) {
    return null;
  }
}

/// Reads bytes from a local file if it exists on disk.
Future<List<int>?> readLocalFileBytes(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  } catch (_) {
    return null;
  }
}

/// Synchronously checks whether a local path points to an existing file.
bool localFileExists(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  if (path.startsWith('http://') || path.startsWith('https://')) return false;
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}

/// Deletes a temporary pending upload file after successful sync.
Future<void> deleteLocalFile(String? path) async {
  if (path == null || path.trim().isEmpty) return;
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {}
}

/// Writes downloaded media bytes into the system temporary directory for
/// playback (e.g. authenticated voice notes) and returns the created file path.
Future<String?> saveTempMediaBytes(
  List<int> bytes, {
  String prefix = 'rxedge_media',
  String extension = 'm4a',
}) async {
  try {
    final dir = await getTemporaryDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final safePrefix = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final safeExt = extension.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final ext = safeExt.isEmpty ? 'm4a' : safeExt;
    final target = File(
      '${dir.path}/${safePrefix}_${DateTime.now().microsecondsSinceEpoch}.$ext',
    );
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  } catch (_) {
    return null;
  }
}

/// Renders an image directly from a local file path.
Widget buildLocalFileImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function()? errorBuilder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) =>
        errorBuilder?.call() ?? const SizedBox.shrink(),
  );
}
