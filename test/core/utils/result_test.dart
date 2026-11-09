import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';

void main() {
  group('Result<T> Contract Tests', () {
    test('Success returns true for isSuccess and exposes data', () {
      const result = Result.success('clinical_dossier_data');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 'clinical_dossier_data');
      expect(result.failureOrNull, isNull);

      final mapped = result.when(
        success: (data) => 'processed_$data',
        failure: (f) => 'failed',
      );
      expect(mapped, 'processed_clinical_dossier_data');
    });

    test('Failure returns true for isFailure and exposes failure', () {
      const failure = NetworkFailure(debugMessage: 'No route to host');
      const result = Result<String>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, failure);

      final folded = result.fold(
        (f) => 'handled_failure',
        (data) => 'success',
      );
      expect(folded, 'handled_failure');
    });

    test('map transforms success and preserves failure', () {
      const success = Result.success(10);
      expect(success.map((v) => v * 2).dataOrNull, 20);

      const failure = Result<int>.failure(ServerFailure(statusCode: 500));
      expect(failure.map((v) => v * 2).isFailure, isTrue);
    });
  });
}
