import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/features/progress/data/progress_repository.dart';
import 'package:zenigo/src/core/services/timer_service.dart';

// 1. Define the State
class RoutinePlayerState {
  const RoutinePlayerState({
    required this.routine,
    this.isPaused = false,
    this.isFinished = false,
    this.currentBlockIndex = 0,
    this.error,
  });

  final Routine routine;
  final bool isPaused;
  final bool isFinished;
  final int currentBlockIndex;
  final String? error;

  // Convenience getter for the current block
  Block? get currentBlock {
    if (currentBlockIndex >= 0 && currentBlockIndex < routine.blocks.length) {
      return routine.blocks[currentBlockIndex];
    }
    return null;
  }

  RoutinePlayerState copyWith({
    Routine? routine,
    bool? isPaused,
    bool? isFinished,
    int? currentBlockIndex,
    String? error,
    bool clearError = false,
  }) {
    return RoutinePlayerState(
      routine: routine ?? this.routine,
      isPaused: isPaused ?? this.isPaused,
      isFinished: isFinished ?? this.isFinished,
      currentBlockIndex: currentBlockIndex ?? this.currentBlockIndex,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// 2. Create the Notifier
class RoutinePlayerController
    extends AutoDisposeFamilyAsyncNotifier<RoutinePlayerState, String> {
  @override
  Future<RoutinePlayerState> build(String routineId) async {
    debugPrint('[Controller] Build called for routineId: $routineId');
    final timerService = ref.read(timerServiceProvider);
    ref.onDispose(() {
      debugPrint('[Controller] Disposing and canceling timer.');
      timerService.cancel();
    });

    try {
      debugPrint('[Controller] Fetching routine...');
      final routine =
          await ref.read(routineRepositoryProvider).getRoutineById(routineId);
      debugPrint('[Controller] Routine fetched: ${routine.title}');

      if (routine.blocks.isEmpty) {
        debugPrint('[Controller] Routine has no blocks, finishing immediately.');
        // If there are no blocks, finish immediately.
        // We can't call _finishRoutine here directly as it modifies state
        // during the build process. Instead, we return a finished state.
        return RoutinePlayerState(routine: routine, isFinished: true);
      } else {
        debugPrint('[Controller] Starting timer for the first block.');
        // Start the timer for the first block.
        _startBlockTimer(routine.blocks.first);
        return RoutinePlayerState(routine: routine);
      }
    } on Exception catch (e, st) {
      debugPrint('[Controller] Error loading routine: $e\n$st');
      throw Exception('Failed to load routine. Please try again.');
    }
  }

  void _startBlockTimer(Block block) {
    debugPrint('[Controller] Starting timer for block: ${block.instruction}');
    ref
        .read(timerServiceProvider)
        .start(Duration(seconds: block.duration), _nextBlock);
  }

  void _nextBlock() {
    if (state.value == null || state.value!.isPaused) {
      debugPrint('[Controller] _nextBlock called but state is null or paused. Returning.');
      return;
    }
    debugPrint('[Controller] _nextBlock called.');

    final currentState = state.value!;
    final routine = currentState.routine;

    // Check if there is a next block
    if (currentState.currentBlockIndex < routine.blocks.length - 1) {
      final newIndex = currentState.currentBlockIndex + 1;
      debugPrint('[Controller] Moving to next block, index: $newIndex');
      state = AsyncData(currentState.copyWith(currentBlockIndex: newIndex));
      _startBlockTimer(routine.blocks[newIndex]);
    } else {
      debugPrint('[Controller] Last block finished, calling _finishRoutine.');
      unawaited(_finishRoutine());
    }
  }

  Future<void> _finishRoutine() async {
    if (state.value == null || state.value!.isFinished) {
      debugPrint('[Controller] _finishRoutine called but state is null or already finished. Returning.');
      return;
    }
    debugPrint('[Controller] Finishing routine.');

    await ref
        .read(progressRepositoryProvider)
        .addSession(state.value!.routine);
    debugPrint('[Controller] Session added to progress.');
    ref.invalidate(dashboardDataProvider);
    debugPrint('[Controller] Dashboard data invalidated.');

    ref.read(timerServiceProvider).cancel();
    debugPrint('[Controller] Timer canceled.');
    state = AsyncData(state.value!.copyWith(isFinished: true));
    debugPrint('[Controller] State updated to isFinished: true.');
  }

  void togglePause() {
    if (state.value == null) return;
    debugPrint('[Controller] togglePause called.');

    final currentState = state.value!;
    final isPaused = !currentState.isPaused;
    debugPrint('[Controller] Toggling pause to: $isPaused');
    state = AsyncData(currentState.copyWith(isPaused: isPaused));

    if (isPaused) {
      ref.read(timerServiceProvider).cancel();
      debugPrint('[Controller] Timer canceled due to pause.');
    } else {
      // Resume the timer
      final currentBlock = currentState.currentBlock;
      if (currentBlock != null) {
        _startBlockTimer(currentBlock);
      }
    }
  }

  void skip() {
    debugPrint('[Controller] skip called.');
    // Stop the current timer and move to the next block
    ref.read(timerServiceProvider).cancel();
    _nextBlock();
  }
}

// 3. Create the Provider
final routinePlayerControllerProvider = AsyncNotifierProvider.autoDispose
    .family<RoutinePlayerController, RoutinePlayerState, String>(
  RoutinePlayerController.new,
);