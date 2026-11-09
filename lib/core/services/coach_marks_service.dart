import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';

const String _coachMarksKey = 'rxedge_coach_marks_completed';

class CoachMarksNotifier extends StateNotifier<bool> {
  final SecureStorageService _storage;

  CoachMarksNotifier({required SecureStorageService storage})
      : _storage = storage,
        super(false) {
    _init();
  }

  Future<void> _init() async {
    final completed = await _storage.read(_coachMarksKey);
    // If not marked completed, we should show it
    if (completed != 'true') {
      state = true;
    }
  }

  Future<void> completeCoachMarks() async {
    state = false;
    await _storage.write(_coachMarksKey, 'true');
  }

  Future<void> resetForTesting() async {
    state = true;
    await _storage.delete(_coachMarksKey);
  }
}

final coachMarksProvider = StateNotifierProvider<CoachMarksNotifier, bool>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return CoachMarksNotifier(storage: storage);
});
