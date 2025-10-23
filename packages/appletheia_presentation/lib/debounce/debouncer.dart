import 'dart:async';

class Debouncer {
  Debouncer({required this.duration});

  final Duration duration;
  Timer? _timer;
  Completer? _completer;

  void run(FutureOr<void> Function() action) async {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(duration, action);
  }

  Future<T> runWait<T>(FutureOr<T> Function() action) {
    _completer ??= Completer<T>();
    final completer = _completer!;
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(duration, () {
      var result = action();
      _completer?.complete(result);
      _completer = null;
    });
    return completer.future as Future<T>;
  }

  void dispose() {
    _timer?.cancel();
  }
}
