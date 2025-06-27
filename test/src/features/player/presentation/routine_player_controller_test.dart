import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/models/routine_category.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/features/player/presentation/routine_player_controller.dart';
import 'package:zenigo/src/features/progress/data/progress_repository.dart';
import 'package:zenigo/src/core/services/timer_service.dart';

import 'routine_player_controller_test.mocks.dart' as mocks;

@GenerateNiceMocks([
  MockSpec<RoutineRepository>(),
  MockSpec<ProgressRepository>(),
  MockSpec<TimerService>()
])
void main() {
  late mocks.MockRoutineRepository mockRoutineRepository;
  late mocks.MockProgressRepository mockProgressRepository;
  late mocks.MockTimerService mockTimerService;
  late ProviderContainer container;

  final testRoutine = Routine(
    id: 'test-id',
    title: 'Test Routine',
    description: 'A test routine.',
    category: RoutineCategory.mindfulMorning,
    blocks: const [
      Block(
          id: 'block-1',
          routineId: 'test-id',
          instruction: 'Block 1',
          duration: 2,
          order: 0),
      Block(
          id: 'block-2',
          routineId: 'test-id',
          instruction: 'Block 2',
          duration: 3,
          order: 1),
    ],
  );

  setUp(() {
    mockRoutineRepository = mocks.MockRoutineRepository();
    mockProgressRepository = mocks.MockProgressRepository();
    mockTimerService = mocks.MockTimerService();
    container = ProviderContainer(
      overrides: [
        routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
        progressRepositoryProvider.overrideWithValue(mockProgressRepository),
        timerServiceProvider.overrideWithValue(mockTimerService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('RoutinePlayerController', () {
    test('initial state is loading, then loads routine', () async {
      // Arrange
      when(mockRoutineRepository.getRoutineById(any))
          .thenAnswer((_) async => testRoutine);
      when(mockProgressRepository.addSession(any)).thenAnswer((_) async => {});

      // Act
      container.read(routinePlayerControllerProvider('test-id').notifier);
      await container.read(routinePlayerControllerProvider('test-id').future);

      // Assert final state
      final state =
          container.read(routinePlayerControllerProvider('test-id')).value!;
      expect(state.routine, testRoutine);
      expect(state.currentBlock?.instruction, 'Block 1');
    });

    test('skip() moves to the next block', () async {
      // Arrange
      when(mockRoutineRepository.getRoutineById(any))
          .thenAnswer((_) async => testRoutine);
      when(mockProgressRepository.addSession(any)).thenAnswer((_) async => {});

      final controller =
          container.read(routinePlayerControllerProvider('test-id').notifier);
      await container.read(routinePlayerControllerProvider('test-id').future);

      // Act
      controller.skip();
      await Future.microtask(() {});

      // Assert
      final state =
          container.read(routinePlayerControllerProvider('test-id')).value!;
      expect(state.currentBlockIndex, 1);
      expect(state.currentBlock?.instruction, 'Block 2');
    });

    test('togglePause() pauses and resumes the timer', () async {
      // Arrange
      when(mockRoutineRepository.getRoutineById(any))
          .thenAnswer((_) async => testRoutine);
      when(mockProgressRepository.addSession(any)).thenAnswer((_) async => {});

      final controller =
          container.read(routinePlayerControllerProvider('test-id').notifier);
      await container.read(routinePlayerControllerProvider('test-id').future);

      // Act 1: Pause
      controller.togglePause();
      await Future.microtask(() {});

      // Assert 1: Paused
      var state =
          container.read(routinePlayerControllerProvider('test-id')).value!;
      expect(state.isPaused, isTrue);

      // Act 2: Resume
      controller.togglePause();
      await Future.microtask(() {});

      // Assert 2: Resumed
      state = container.read(routinePlayerControllerProvider('test-id')).value!;
      expect(state.isPaused, isFalse);
    });
  });
}