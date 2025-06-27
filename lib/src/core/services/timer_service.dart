import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An abstract service for creating timers, allowing for mock implementations in tests.
abstract class TimerService {
  /// Starts a new timer.
  void start(Duration duration, VoidCallback callback);

  /// Cancels the current timer.
  void cancel();

  /// Returns true if the timer is currently active.
  bool get isActive;
}

/// The real implementation of the TimerService using dart:async's Timer.
class TimerServiceImpl implements TimerService {
  Timer? _timer;

  @override
  bool get isActive => _timer?.isActive ?? false;

  @override
  void start(Duration duration, VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// A mock implementation for testing purposes.
@visibleForTesting
class MockTimerService implements TimerService {
  VoidCallback? _callback;

  @override
  bool get isActive => _callback != null;

  @override
  void start(Duration duration, VoidCallback callback) {
    _callback = callback;
  }

  @override
  void cancel() {
    _callback = null;
  }

  /// A test-only method to manually trigger the timer's callback.
  void fire() {
    _callback?.call();
    _callback = null;
  }
}

/// Riverpod provider for the TimerService.
///
/// This can be overridden in tests to provide the [MockTimerService].
final timerServiceProvider = Provider<TimerService>((ref) {
  return TimerServiceImpl();
});