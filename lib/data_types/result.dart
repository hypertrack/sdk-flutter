class Result<T, E> {
  Result._();

  factory Result.success(T value) = Success;
  factory Result.error(E error) = Error;
}

class Error<T, E> extends Result<T, E> {
  Error(this.error): super._();

  final E error;

  @override
  String toString() {
    return error.toString();
  }
}

class Success<T, E> extends Result<T, E> {
  Success(this.value): super._();

  final T value;

  @override
  String toString() {
    return value.toString();
  }
}
