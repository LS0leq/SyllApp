import 'failures.dart';


export 'failures.dart';





















sealed class Result<T> {
  const Result();

  
  bool get isSuccess => this is Success<T>;

  
  bool get isFailure => this is Err<T>;

  
  T getOrElse(T Function() orElse) {
    return switch (this) {
      Success(:final value) => value,
      Err() => orElse(),
    };
  }

  
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(:final value) => Success(transform(value)),
      Err(:final failure) => Err(failure),
    };
  }
}


final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}


final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
