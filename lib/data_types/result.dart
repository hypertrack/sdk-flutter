class Result<T, E> {
  Result._();

  factory Result.success(T value) = Success;

  factory Result.error(E error) = Failure;

  /// @nodoc
  @override
  String toString() {
    return super.toString();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

class Failure<T, E> extends Result<T, E> {
  Failure(this.failure) : super._();

  final E failure;

  /// @nodoc
  @override
  String toString() {
    return failure.toString();
  }

  /// @nodoc
  @override
  // ignore: unnecessary_no_such_method
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}

class Success<T, E> extends Result<T, E> {
  Success(this.value) : super._();

  final T value;

  /// @nodoc
  @override
  String toString() {
    return value.toString();
  }

  /// @nodoc
  @override
  // ignore: unnecessary_no_such_method
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  /// @nodoc
  @override
  bool operator ==(Object other) {
    return super == other;
  }

  /// @nodoc
  @override
  int get hashCode {
    return super.hashCode;
  }

  /// @nodoc
  @override
  Type get runtimeType {
    return super.runtimeType;
  }
}
