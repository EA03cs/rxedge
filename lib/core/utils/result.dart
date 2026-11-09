import '../error/failures.dart';

/// Sealed Result type representing either a successful outcome [Success]
/// or a failed outcome [FailureResult].
///
/// Follows Architecture Contract:
/// "Repositories return `Result<T>`, never throw into the UI."
sealed class Result<T> {
  const Result();

  /// Create a successful result
  const factory Result.success(T data) = Success<T>;

  /// Create a failure result
  const factory Result.failure(Failure failure) = FailureResult<T>;

  /// Returns true if this is [Success]
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is [FailureResult]
  bool get isFailure => this is FailureResult<T>;

  /// Returns data if [Success], otherwise null
  T? get dataOrNull {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }

  /// Returns Failure if [FailureResult], otherwise null
  Failure? get failureOrNull {
    if (this is FailureResult<T>) {
      return (this as FailureResult<T>).failure;
    }
    return null;
  }

  /// Pattern matching over result states
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as FailureResult<T>).failure);
    }
  }

  /// Fold operation matching Either semantics
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as FailureResult<T>).failure);
    }
  }

  /// Transforms successful value
  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      return Result.success(transform((this as Success<T>).data));
    } else {
      return Result.failure((this as FailureResult<T>).failure);
    }
  }
}

/// Represents a successful result containing [data]
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Result.success($data)';
}

/// Represents a failure result containing a [failure]
final class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Result.failure($failure)';
}
