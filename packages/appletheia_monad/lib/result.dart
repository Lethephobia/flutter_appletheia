sealed class Result<T, E extends Exception> {
  bool get isOk;
  bool get isErr;

  T? get ok;

  E? get err;

  Result<U, E> map<U>(U Function(T) toValue);

  U mapOr<U>(U defaultValue, U Function(T) toValue);

  U mapOrElse<U>(U Function(E) onErr, U Function(T) toValue);

  Result<T, F> mapErr<F extends Exception>(F Function(E) toErr);

  Result<T, E> inspect(void Function(T) onOk);

  Result<T, E> inspectErr(void Function(E) onErr);

  T expect(String message);

  T unwrap();

  E expectErr(String message);

  E unwrapErr();

  Result<U, E> and<U>(Result<U, E> result);

  Result<U, E> andThen<U>(Result<U, E> Function(T) toResult);

  Result<T, F> or<F extends Exception>(Result<T, F> result);

  Result<T, F> orElse<F extends Exception>(Result<T, F> Function(E) toResult);

  T unwrapOr(T defaultValue);

  T unwrapOrElse(T Function(E) onErr);

  Result<T, E> copy();
}

class Ok<T, E extends Exception> implements Result<T, E> {
  const Ok(this.value);

  final T value;

  @override
  bool get isOk => true;

  @override
  bool get isErr => false;

  @override
  T? get ok => value;

  @override
  E? get err => null;

  @override
  Result<U, E> map<U>(U Function(T) toValue) => Ok(toValue(value));

  @override
  U mapOr<U>(U defaultValue, U Function(T) toValue) => toValue(value);

  @override
  U mapOrElse<U>(U Function(E) onErr, U Function(T) toValue) => toValue(value);

  @override
  Result<T, F> mapErr<F extends Exception>(F Function(E) toErr) => Ok(value);

  @override
  Result<T, E> inspect(void Function(T) onOk) {
    onOk(value);
    return this;
  }

  @override
  Result<T, E> inspectErr(void Function(E) onErr) => this;

  @override
  T expect(String message) => value;

  @override
  T unwrap() => value;

  @override
  E expectErr(String message) {
    throw Exception(message);
  }

  @override
  E unwrapErr() {
    throw Exception('UnwrapErr called on Ok');
  }

  @override
  Result<U, E> and<U>(Result<U, E> result) => result;

  @override
  Result<U, E> andThen<U>(Result<U, E> Function(T) toResult) => toResult(value);

  @override
  Result<T, F> or<F extends Exception>(Result<T, F> result) => Ok(value);

  @override
  Result<T, F> orElse<F extends Exception>(Result<T, F> Function(E) toResult) {
    return Ok(value);
  }

  @override
  T unwrapOr(T defaultValue) => value;

  @override
  T unwrapOrElse(T Function(E) onErr) => value;

  @override
  Result<T, E> copy() => Ok(value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Ok) {
      return false;
    }
    return value == other.value;
  }

  @override
  int get hashCode {
    return value.hashCode;
  }
}

class Err<T, E extends Exception> implements Result<T, E> {
  const Err(this.error);

  final E error;

  @override
  bool get isOk => false;

  @override
  bool get isErr => true;

  @override
  T? get ok => null;

  @override
  E? get err => error;

  @override
  Result<U, E> map<U>(U Function(T) toValue) => Err(error);

  @override
  U mapOr<U>(U defaultValue, U Function(T) toValue) => defaultValue;

  @override
  U mapOrElse<U>(U Function(E) onErr, U Function(T) toValue) => onErr(error);

  @override
  Result<T, F> mapErr<F extends Exception>(F Function(E) toErr) =>
      Err(toErr(error));

  @override
  Result<T, E> inspect(void Function(T) onOk) => this;

  @override
  Result<T, E> inspectErr(void Function(E) onErr) {
    onErr(error);
    return this;
  }

  @override
  T expect(String message) {
    throw Exception(message);
  }

  @override
  T unwrap() {
    throw Exception('Unwrap called on Err');
  }

  @override
  E expectErr(String message) => error;

  @override
  E unwrapErr() => error;

  @override
  Result<U, E> and<U>(Result<U, E> result) => Err(error);

  @override
  Result<U, E> andThen<U>(Result<U, E> Function(T) toResult) => Err(error);

  @override
  Result<T, F> or<F extends Exception>(Result<T, F> result) => result;

  @override
  Result<T, F> orElse<F extends Exception>(Result<T, F> Function(E) toResult) {
    return toResult(error);
  }

  @override
  T unwrapOr(T defaultValue) => defaultValue;

  @override
  T unwrapOrElse(T Function(E) onErr) => onErr(error);

  @override
  Result<T, E> copy() => Err(error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Err) {
      return false;
    }
    return error == other.error;
  }

  @override
  int get hashCode {
    return error.hashCode;
  }
}
