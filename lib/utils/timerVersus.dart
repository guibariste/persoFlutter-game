import 'dart:async';

class CountdownTimerVersus {
  late Timer _timer;
  int _secondsRemaining = 30;
  Function(int) _onTick;
  Function() _onComplete;
  bool _isRunning = false;

  CountdownTimerVersus({
    required Function(int) onTick,
    required Function() onComplete,
  })  : _onTick = onTick,
        _onComplete = onComplete;

  void start() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _secondsRemaining--;
        _onTick(_secondsRemaining);

        if (_secondsRemaining <= 0) {
          _timer.cancel();
          _onComplete();
          _isRunning = false;
        }
      });
    }
  }

  void cancel() {
    _timer.cancel();
    _isRunning = false;
    _secondsRemaining = 120;
  }

  bool get isActive => _isRunning;
}
