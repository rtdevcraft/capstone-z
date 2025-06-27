import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/features/library/presentation/content_library_screen.dart';
import 'package:zenigo/src/features/player/data/routine_repository.dart';
import 'package:zenigo/src/core/services/logger_service.dart';

class RoutineEditorController extends StateNotifier<AsyncValue<Routine?>> {
  RoutineEditorController({
    required this.routineRepository,
    required this.ref,
  }) : super(const AsyncData(null));

  final RoutineRepository routineRepository;
  final Ref ref;

  Future<Routine?> saveRoutine(Routine routine) async {
    logger.i('RoutineEditorController: saveRoutine started');
    state = const AsyncValue.loading();
    final newState = await AsyncValue.guard(() async {
      final savedRoutine = await routineRepository.saveRoutine(routine);
      ref.invalidate(allRoutinesProvider);
      return savedRoutine;
    });
    state = newState;
    logger.i('RoutineEditorController: saveRoutine finished');
    return newState.value;
  }

  Future<void> deleteRoutine(String routineId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await routineRepository.deleteRoutine(routineId);
      ref.invalidate(allRoutinesProvider);
      return null;
    });
  }
}

final routineEditorControllerProvider =
    StateNotifierProvider<RoutineEditorController, AsyncValue<Routine?>>((ref) {
  return RoutineEditorController(
    routineRepository: ref.watch(routineRepositoryProvider),
    ref: ref,
  );
});