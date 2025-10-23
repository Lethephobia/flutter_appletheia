import 'result.dart';

sealed class Option<T> {
  bool get isSome;
  bool get isNone;

  bool isSomeAnd(bool Function(T) test);

  bool isNoneOr(bool Function(T) test);

  T expect(String message);

  T unwrap();

  T unwrapOr(T defaultValue);

  T unwrapOrElse(T Function() onNone);

  Option<U> map<U>(U Function(T) toValue);

  Option<T> inspect(void Function(T) onSome);

  U mapOr<U>(U defaultValue, U Function(T) toValue);

  U mapOrElse<U>(U Function() onNone, U Function(T) toValue);

  Result<T, E> okOr<E extends Exception>(E err);

  Result<T, E> okOrElse<E extends Exception>(E Function() onNone);

  Option<U> and<U>(Option<U> other);

  Option<U> andThen<U>(Option<U> Function(T) toOption);

  Option<T> filter(bool Function(T) predicate);

  Option<T> or(Option<T> other);

  Option<T> orElse(Option<T> Function() onNone);

  Option<T> xor(Option<T> other);

  Option<(T, U)> zip<U>(Option<U> other);

  Option<T> copy();
}

class None<T> implements Option<T> {
  const None();

  @override
  bool get isSome => false;

  @override
  bool get isNone => true;

  @override
  bool isSomeAnd(bool Function(T) test) => false;

  @override
  bool isNoneOr(bool Function(T) test) => true;

  @override
  T expect(String message) => throw Exception(message);

  @override
  T unwrap() => throw Exception('Unwrap called on None');

  @override
  T unwrapOr(T defaultValue) => defaultValue;

  @override
  T unwrapOrElse(T Function() onNone) => onNone();

  @override
  Option<U> map<U>(U Function(T) toValue) => None();

  @override
  Option<T> inspect(void Function(T) onSome) => this;

  @override
  U mapOr<U>(U defaultValue, U Function(T) toValue) => defaultValue;

  @override
  U mapOrElse<U>(U Function() onNone, U Function(T) toValue) => onNone();

  @override
  Result<T, E> okOr<E extends Exception>(E err) => Err(err);

  @override
  Result<T, E> okOrElse<E extends Exception>(E Function() onNone) =>
      Err(onNone());

  @override
  Option<U> and<U>(Option<U> other) => None();

  @override
  Option<U> andThen<U>(Option<U> Function(T) toOption) => None();

  @override
  Option<T> filter(bool Function(T) predicate) => this;

  @override
  Option<T> or(Option<T> other) => other;

  @override
  Option<T> orElse(Option<T> Function() onNone) => onNone();

  @override
  Option<T> xor(Option<T> other) => other.isSome ? other : this;

  @override
  Option<(T, U)> zip<U>(Option<U> other) => None();

  @override
  Option<T> copy() => None();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! None) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return 0;
  }
}

class Some<T> implements Option<T> {
  const Some(this.value);

  final T value;

  @override
  bool get isSome => true;

  @override
  bool get isNone => false;

  @override
  bool isSomeAnd(bool Function(T) test) => test(value);

  @override
  bool isNoneOr(bool Function(T) test) => test(value);

  @override
  T expect(String message) => value;

  @override
  T unwrap() => value;

  @override
  T unwrapOr(T defaultValue) => value;

  @override
  T unwrapOrElse(T Function() onNone) => value;

  @override
  Option<U> map<U>(U Function(T) toValue) => Some(toValue(value));

  @override
  Option<T> inspect(void Function(T) onSome) {
    onSome(value);
    return this;
  }

  @override
  U mapOr<U>(U defaultValue, U Function(T) toValue) => toValue(value);

  @override
  U mapOrElse<U>(U Function() onNone, U Function(T) toValue) => toValue(value);

  @override
  Result<T, E> okOr<E extends Exception>(E err) => Ok(value);

  @override
  Result<T, E> okOrElse<E extends Exception>(E Function() onNone) => Ok(value);

  @override
  Option<U> and<U>(Option<U> other) => other;

  @override
  Option<U> andThen<U>(Option<U> Function(T) toOption) => toOption(value);

  @override
  Option<T> filter(bool Function(T) predicate) =>
      predicate(value) ? this : None();

  @override
  Option<T> or(Option<T> other) => this;

  @override
  Option<T> orElse(Option<T> Function() onNone) => this;

  @override
  Option<T> xor(Option<T> other) => other.isSome ? None() : this;

  @override
  Option<(T, U)> zip<U>(Option<U> other) =>
      other.isSome ? Some((value, other.unwrap())) : None();

  @override
  Option<T> copy() => Some(value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Some) {
      return false;
    }
    return value == other.value;
  }

  @override
  int get hashCode {
    return value.hashCode;
  }
}
