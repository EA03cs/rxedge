import 'package:hive_flutter/hive_flutter.dart';
import '../services/logger_service.dart';

/// Initializes persistent Hive boxes used across caching, offline queues,
/// and user preferences (locale, theme mode).
///
/// Safe to call once on app startup; storage services automatically fall back
/// to in-memory structures in pure unit tests where Hive isn't initialized.
abstract final class StorageInitializer {
  static const String cacheBoxName = 'rxedge_cache';
  static const String offlineQueueBoxName = 'rxedge_offline_queue';
  static const String preferencesBoxName = 'rxedge_preferences';

  static const String prefLocaleKey = 'locale_code';
  static const String prefThemeModeKey = 'theme_mode';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox<String>(cacheBoxName),
        Hive.openBox<String>(offlineQueueBoxName),
        Hive.openBox<String>(preferencesBoxName),
      ]);
      _initialized = true;
      AppLogger.i('Hive storage boxes initialized', tag: 'Storage');
    } catch (e, st) {
      AppLogger.w(
        'Hive initialization skipped or failed; falling back to memory',
        tag: 'Storage',
        error: e,
        stackTrace: st,
      );
    }
  }

  static String? readPreference(String key) {
    if (!Hive.isBoxOpen(preferencesBoxName)) return null;
    return Hive.box<String>(preferencesBoxName).get(key);
  }

  static Future<void> writePreference(String key, String value) async {
    if (!Hive.isBoxOpen(preferencesBoxName)) return;
    await Hive.box<String>(preferencesBoxName).put(key, value);
  }

  static String readInitialLocaleCode({String fallback = 'ar'}) {
    final stored = readPreference(prefLocaleKey);
    if (stored == 'ar' || stored == 'en') {
      return stored!;
    }
    return fallback;
  }
}
