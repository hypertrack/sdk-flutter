class Result<T, E> {
  Result._();

  factory Result.success(T value) = Success;
  factory Result.error(E error) = Error;
}

class Error<T, E> extends Result<T, E> {
  Error(this.error): super._();

  final E error;
}

class Success<T, E> extends Result<T, E> {
  Success(this.value): super._();

  final T value;
}
