import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/src/core/models/block.dart';
import 'package:zenigo/src/core/models/routine.dart';
import 'package:zenigo/src/core/services/logger_service.dart';
import 'package:zenigo/src/features/player/data/routine_api.dart';
import 'package:zenigo/src/features/player/data/supabase_routine_api.dart';

/// Custom exception for routine-related errors.
class RoutineException implements Exception {
  /// The error message.
  const RoutineException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => message;
}

/// A repository for fetching routine data from the Supabase database.
class RoutineRepository {
  RoutineRepository(this._api);
  final RoutineApi _api;

  Future<List<Routine>> getAllRoutines() async {
    logger.i('RoutineRepository: getAllRoutines started');
    try {
      final data = await _api.fetchAllRoutines();
      logger.i('RoutineRepository: getAllRoutines fetched data: $data');
      return data.map((item) => Routine.fromJson(item)).toList();
    } catch (e, stackTrace) {
      logger.e('RoutineRepository: Error in getAllRoutines',
          error: e, stackTrace: stackTrace);
      throw const RoutineException(
          'An unexpected error occurred while fetching routines.');
    }
  }

  Future<Routine> getRoutineById(String id) async {
    try {
      final routineData = await _api.fetchRoutineById(id);
      if (routineData == null) {
        throw const RoutineException('Routine not found or access denied.');
      }
      final routine = Routine.fromJson(routineData);
      final blocksData = await _api.fetchBlocksForRoutine(id);
      final blocks = blocksData.map((item) => Block.fromJson(item)).toList();
      return routine.copyWith(blocks: blocks);
    } catch (e, stackTrace) {
      logger.e('RoutineRepository: Error in getRoutineById',
          error: e, stackTrace: stackTrace);
      throw const RoutineException(
          'An unexpected error occurred while fetching the routine.');
    }
  }

  Future<Routine> saveRoutine(Routine routine) async {
    logger.i('RoutineRepository: saveRoutine started for routine id ${routine.id}');
    try {
      final routineData = routine.toJson()..remove('blocks');
      final savedRoutineData = await _api.saveRoutine(routineData);
      final savedRoutine = Routine.fromJson(savedRoutineData);
      logger.i('RoutineRepository: routine upserted with id: ${savedRoutine.id}');

      await _api.deleteBlocksForRoutine(savedRoutine.id);

      List<Block> savedBlocks = [];
      if (routine.blocks.isNotEmpty) {
        logger.i('Inserting ${routine.blocks.length} blocks for routine ${savedRoutine.id}');
        final blocksData = routine.blocks
            .asMap()
            .entries
            .map((e) => e.value
                .copyWith(routineId: savedRoutine.id, order: e.key)
                .toJson())
            .toList();
        final insertedBlocksData = await _api.saveBlocks(blocksData);
        savedBlocks =
            insertedBlocksData.map((item) => Block.fromJson(item)).toList();
      }

      final finalRoutine = savedRoutine.copyWith(blocks: savedBlocks);
      logger.i('RoutineRepository: saveRoutine finished successfully');
      return finalRoutine;
    } catch (e, stackTrace) {
      logger.e('RoutineRepository: Error in saveRoutine',
          error: e, stackTrace: stackTrace);
      throw const RoutineException(
          'An unexpected error occurred while saving the routine.');
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    logger.i('RoutineRepository: deleteRoutine started for id: $routineId');
    try {
      final routine = await getRoutineById(routineId);
      if (routine.userId == null) {
        throw const RoutineException('This routine cannot be deleted.');
      }
      await _api.deleteRoutine(routineId);
      logger.i('RoutineRepository: deleteRoutine finished successfully for id: $routineId');
    } catch (e, stackTrace) {
      logger.e('RoutineRepository: Error in deleteRoutine',
          error: e, stackTrace: stackTrace);
      throw const RoutineException(
          'An unexpected error occurred while deleting the routine.');
    }
  }
}

final routineApiProvider = Provider<RoutineApi>((ref) {
  final client = Supabase.instance.client;
  return SupabaseRoutineApi(client);
});

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final api = ref.watch(routineApiProvider);
  return RoutineRepository(api);
});