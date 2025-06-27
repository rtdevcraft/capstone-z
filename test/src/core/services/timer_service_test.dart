import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:zenigo/src/core/services/timer_service.dart';

void main() {
  group('TimerService', () {
    test('timer completes after specified duration', () {
      fakeAsync((async) {
        final timerService = TimerServiceImpl();
        bool completed = false;
        void onComplete() {
          completed = true;
        }

        timerService.start(const Duration(seconds: 5), onComplete);

        async.elapse(const Duration(seconds: 5));
        expect(completed, isTrue);
      });
    });

    test('timer does not complete before specified duration', () {
      fakeAsync((async) {
        final timerService = TimerServiceImpl();
        bool completed = false;
        void onComplete() {
          completed = true;
        }

        timerService.start(const Duration(seconds: 5), onComplete);

        async.elapse(const Duration(seconds: 4));
        expect(completed, isFalse);
      });
    });

    test('cancel() stops the timer', () {
      fakeAsync((async) {
        final timerService = TimerServiceImpl();
        bool completed = false;
        void onComplete() {
          completed = true;
        }

        timerService.start(const Duration(seconds: 5), onComplete);
        timerService.cancel();

        async.elapse(const Duration(seconds: 5));
        expect(completed, isFalse);
      });
    });

    test('is active after start and inactive after completion', () {
      fakeAsync((async) {
        final timerService = TimerServiceImpl();
        void onComplete() {}

        timerService.start(const Duration(seconds: 5), onComplete);
        expect(timerService.isActive, isTrue);

        async.elapse(const Duration(seconds: 5));
        expect(timerService.isActive, isFalse);
      });
    });

    test('is active after start and inactive after cancel', () {
      fakeAsync((async) {
        final timerService = TimerServiceImpl();
        void onComplete() {}

        timerService.start(const Duration(seconds: 5), onComplete);
        expect(timerService.isActive, isTrue);

        timerService.cancel();
        expect(timerService.isActive, isFalse);
      });
    });
  });
}