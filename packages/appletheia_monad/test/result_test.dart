import 'package:appletheia_monad/appletheia_monad.dart';
import 'package:flutter_test/flutter_test.dart';

class _InputException implements Exception {
  const _InputException(this.message);
  final String message;
}

class _NetworkException implements Exception {
  const _NetworkException(this.code);
  final int code;
}

void main() {
  group('Result', () {
    test('Ok state exposes value and guards err operations', () {
      final result = Ok<int, Exception>(10);

      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.ok, 10);
      expect(result.err, isNull);
      expect(result.expect('unreachable'), 10);
      expect(result.unwrap(), 10);
      expect(() => result.expectErr('should fail'), throwsA(isA<Exception>()));
      expect(() => result.unwrapErr(), throwsA(isA<Exception>()));
    });

    test('Err state exposes error and guards ok operations', () {
      final error = _InputException('invalid');
      final result = Err<int, _InputException>(error);

      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
      expect(result.ok, isNull);
      expect(result.err, error);
      expect(() => result.expect('needs ok'), throwsA(isA<Exception>()));
      expect(() => result.unwrap(), throwsA(isA<Exception>()));
      expect(result.expectErr('message'), error);
      expect(result.unwrapErr(), error);
    });

    test('map, mapOr, and mapOrElse transform Ok values', () {
      final ok = Ok<int, Exception>(4);
      final err = Err<int, Exception>(Exception('boom'));

      expect(ok.map((value) => value * 2), Ok<int, Exception>(8));
      expect(err.map((value) => value * 2), Err<int, Exception>(err.err!));

      expect(ok.mapOr(0, (value) => value + 1), 5);
      expect(err.mapOr(0, (value) => value + 1), 0);

      expect(ok.mapOrElse((error) => -1, (value) => value - 2), 2);
      expect(err.mapOrElse((error) => -1, (value) => value - 2), -1);
    });

    test('mapErr transforms error value', () {
      final err = Err<int, _InputException>(const _InputException('bad'));
      final mapped = err.mapErr(
        (error) => _NetworkException(error.message.length),
      );

      expect(mapped, isA<Err<int, _NetworkException>>());
      expect((mapped as Err<int, _NetworkException>).err?.code, 3);
    });

    test('inspect and inspectErr run for matching states only', () {
      var okInspections = 0;
      var errInspections = 0;

      Ok<String, Exception>('value')
          .inspect((value) {
            expect(value, 'value');
            okInspections += 1;
          })
          .inspectErr((error) {
            errInspections += 10;
          });

      Err<String, Exception>(Exception('oops'))
          .inspect((value) {
            okInspections += 10;
          })
          .inspectErr((error) {
            errInspections += 1;
          });

      expect(okInspections, 1);
      expect(errInspections, 1);
    });

    test('and and andThen propagate errors and values correctly', () {
      final ok = Ok<int, Exception>(2);
      final err = Err<int, Exception>(Exception('error'));

      expect(
        ok.and(Ok<String, Exception>('next')),
        Ok<String, Exception>('next'),
      );
      expect(ok.and(err), err);
      expect(err.and(Ok<String, Exception>('never')), err);

      expect(
        ok.andThen((value) => Ok<String, Exception>('value: $value')),
        Ok<String, Exception>('value: 2'),
      );
      expect(
        ok.andThen((value) => Err<String, Exception>(Exception('stop'))),
        isA<Err<String, Exception>>(),
      );
      expect(err.andThen((value) => Ok<String, Exception>('never')), err);
    });

    test('or and orElse select fallback on Err', () {
      final ok = Ok<int, _InputException>(5);
      final err = Err<int, _InputException>(const _InputException('bad'));
      final replacement = Ok<int, _NetworkException>(7);

      expect(ok.or(replacement), Ok<int, _NetworkException>(5));
      expect(err.or(replacement), replacement);

      expect(
        ok.orElse((error) => Ok<int, _NetworkException>(error.message.length)),
        Ok<int, _NetworkException>(5),
      );
      expect(
        err.orElse((error) => Ok<int, _NetworkException>(error.message.length)),
        Ok<int, _NetworkException>(3),
      );
    });

    test('unwrapOr and unwrapOrElse provide defaults', () {
      final ok = Ok<int, Exception>(9);
      final err = Err<int, Exception>(Exception('fail'));

      expect(ok.unwrapOr(0), 9);
      expect(err.unwrapOr(0), 0);

      expect(ok.unwrapOrElse((error) => -1), 9);
      expect(err.unwrapOrElse((error) => -1), -1);
    });

    test('copy produces equal result sharing payload', () {
      final ok = Ok<List<int>, Exception>([1, 2, 3]);
      final err = Err<List<int>, Exception>(Exception('err'));

      final okCopy = ok.copy();
      final errCopy = err.copy();

      expect(okCopy, ok);
      expect(errCopy, err);

      // Mutate payload to confirm reference equality for Ok copies.
      (okCopy as Ok<List<int>, Exception>).value.add(4);
      expect(ok.value, [1, 2, 3, 4]);
    });
  });
}
