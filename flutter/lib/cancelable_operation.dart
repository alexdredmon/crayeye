// FILENAME: cancelable_operation.dart
import 'dart:async';

class CancelableOperation<T> {
  CancelableOperation.fromFuture(Future<T> future) : _future = future {
    _completer = Completer<T>();
    future.then((result) {
      if (!_completer.isCompleted) {
        _completer.complete(result);
      }
    }, onError: (error) {
      if (!_completer.isCompleted) {
        _completer.completeError(error);
      }
    });
  }

  final Future<T> _future;
  late final Completer<T> _completer;
  bool _isCanceled = false;

  Future<T> get future => _completer.future;

  void cancel() {
    _isCanceled = true;
    _completer.complete(null as T);
  }

  bool get isCanceled => _isCanceled;

  bool get isCompleted => _completer.isCompleted;
}
// eof
