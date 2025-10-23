import 'package:appletheia_monad/appletheia_monad.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestException implements Exception {
  const _TestException(this.message);
  final String message;
}

void main() {
  group('Option', () {
    test('Some exposes its value and state helpers', () {
      final option = Some(42);

      expect(option.isSome, isTrue);
      expect(option.isNone, isFalse);
      expect(option.isSomeAnd((value) => value > 40), isTrue);
      expect(option.isSomeAnd((value) => value > 50), isFalse);
      expect(option.isNoneOr((value) => value == 42), isTrue);
      expect(option.expect('unreachable'), 42);
      expect(option.unwrap(), 42);
    });

    test('None reports absence', () {
      final option = None<int>();

      expect(option.isSome, isFalse);
      expect(option.isNone, isTrue);
      expect(option.isSomeAnd((value) => true), isFalse);
      expect(option.isNoneOr((value) => false), isTrue);
      expect(() => option.expect('missing value'), throwsA(isA<Exception>()));
      expect(() => option.unwrap(), throwsA(isA<Exception>()));
    });

    test('unwrapOr and unwrapOrElse provide fallbacks', () {
      expect(Some(10).unwrapOr(20), 10);
      expect(None<int>().unwrapOr(20), 20);

      expect(Some(5).unwrapOrElse(() => 99), 5);
      expect(None<int>().unwrapOrElse(() => 99), 99);
    });

    test('map, mapOr, and mapOrElse transform values', () {
      expect(Some(2).map((value) => value * 2), Some(4));
      expect(None<int>().map((value) => value * 2), None<int>());

      expect(Some(3).mapOr(0, (value) => value + 1), 4);
      expect(None<int>().mapOr(7, (value) => value + 1), 7);

      expect(Some(1).mapOrElse(() => -1, (value) => value + 2), 3);
      expect(None<int>().mapOrElse(() => -1, (value) => value + 2), -1);
    });

    test('inspect executes only for Some', () {
      var inspectedValue = 0;
      var inspectionCount = 0;

      Some(9).inspect((value) {
        inspectedValue = value;
        inspectionCount += 1;
      });
      None<int>().inspect((_) => inspectionCount += 10);

      expect(inspectedValue, 9);
      expect(inspectionCount, 1);
    });

    test('okOr and okOrElse lift to Result', () {
      final ok = Some('data').okOr(Exception('error'));
      final err = None<String>().okOr(_TestException('missing'));
      final lazyErr = None<String>().okOrElse(() => _TestException('lazy'));

      expect(ok, Ok<String, Exception>('data'));
      expect(err, isA<Err>());
      expect(err.err, isA<_TestException>());
      expect(lazyErr.err?.message, 'lazy');
    });

    test('and, andThen chain correctly', () {
      expect(Some(1).and(Some('value')), Some('value'));
      expect(Some(1).and(None<String>()), None<String>());
      expect(None<int>().and(Some('value')), None<String>());

      expect(Some(2).andThen((value) => Some(value * 3)), Some(6));
      expect(
        Some(2).andThen((value) => value.isEven ? Some(value) : None<int>()),
        Some(2),
      );
      expect(None<int>().andThen((value) => Some(value * 2)), None<int>());
    });

    test('filter keeps matching values', () {
      expect(Some(4).filter((value) => value.isEven), Some(4));
      expect(Some(5).filter((value) => value.isEven), None<int>());
      expect(None<int>().filter((value) => true), None<int>());
    });

    test('or and orElse return fallbacks', () {
      expect(Some(1).or(Some(2)), Some(1));
      expect(None<int>().or(Some(2)), Some(2));

      expect(Some(3).orElse(() => Some(4)), Some(3));
      expect(None<int>().orElse(() => Some(4)), Some(4));
    });

    test('xor returns value when only one is Some', () {
      expect(Some(1).xor(None<int>()), Some(1));
      expect(None<int>().xor(Some(2)), Some(2));
      expect(Some(1).xor(Some(2)), None<int>());
      expect(None<int>().xor(None<int>()), None<int>());
    });

    test('zip combines values when both are Some', () {
      final zipped = Some(1).zip(Some('a'));
      final noneLeft = None<int>().zip(Some('a'));
      final noneRight = Some(1).zip(None<String>());

      expect(zipped, Some((1, 'a')));
      expect(noneLeft, None<(int, String)>());
      expect(noneRight, None<(int, String)>());
    });

    test('copy creates an equivalent option', () {
      final some = Some({'key': 'value'});
      final none = None<int>();

      final someCopy = some.copy();
      final noneCopy = none.copy();

      expect(someCopy, equals(some));
      expect(noneCopy, equals(none));

      // Ensure the copy retains the same reference for mutable payloads.
      (someCopy as Some<Map<String, String>>).value['extra'] = 'data';
      expect(some.value.containsKey('extra'), isTrue);
    });
  });
}
