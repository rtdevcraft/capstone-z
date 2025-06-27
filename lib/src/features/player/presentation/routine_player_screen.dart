import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenigo/src/features/player/presentation/animated_instruction.dart';
import 'package:zenigo/src/features/player/presentation/routine_player_controller.dart';
import 'package:zenigo/src/shared/constants/app_icons.dart';

class RoutinePlayerScreen extends ConsumerWidget {
  const RoutinePlayerScreen({super.key, required this.routineId});
  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[PlayerScreen] Build called.');
    final controller =
        ref.read(routinePlayerControllerProvider(routineId).notifier);
    final state = ref.watch(routinePlayerControllerProvider(routineId));
    debugPrint('[PlayerScreen] State is: ${state.runtimeType}');


    // Listen to the state and pop the screen when the routine is finished.
    ref.listen<AsyncValue<RoutinePlayerState>>(
      routinePlayerControllerProvider(routineId),
      (previous, next) {
        debugPrint('[PlayerScreen] Listener triggered. Next state isFinished: ${next.value?.isFinished}');
        if (next.value?.isFinished == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            debugPrint('[PlayerScreen] isFinished is true, checking canPop.');
            // Use Navigator.of(context) to align with MockNavigatorProvider
            if (Navigator.of(context).canPop()) {
              debugPrint('[PlayerScreen] Popping navigator.');
              Navigator.of(context).pop();
            } else {
              debugPrint('[PlayerScreen] Cannot pop navigator.');
            }
          });
        }
      },
    );

    return state.when(
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Text(
            error.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
      data: (data) {
        final routine = data.routine;
        final block = data.currentBlock;

        return Scaffold(
          backgroundColor: const Color(0xFF1A3A3A),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(routine.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white)),
                      IconButton(
                        icon: const Icon(AppIcons.close, color: Colors.white),
                        // Use Navigator.of(context) to align with MockNavigatorProvider
                        onPressed: () {
                          debugPrint('[PlayerScreen] Close button tapped.');
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: block == null
                        ? const SizedBox()
                        : AnimatedInstruction(
                            key: ValueKey(
                                block.instruction), // Ensure widget rebuilds
                            instruction: block.instruction,
                            duration: Duration(seconds: block.duration),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 48),
                      IconButton(
                        icon: Icon(
                            data.isPaused ? AppIcons.play : AppIcons.pause,
                            size: 48,
                            color: Colors.white),
                        onPressed: controller.togglePause,
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.skipNext,
                            size: 28, color: Colors.white),
                        onPressed: controller.skip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}