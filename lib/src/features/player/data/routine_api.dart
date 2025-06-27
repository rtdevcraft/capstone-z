
abstract class RoutineApi {
  Future<List<Map<String, dynamic>>> fetchAllRoutines();
  Future<Map<String, dynamic>?> fetchRoutineById(String id);
  Future<List<Map<String, dynamic>>> fetchBlocksForRoutine(String routineId);
  Future<Map<String, dynamic>> saveRoutine(Map<String, dynamic> routineData);
  Future<void> deleteRoutine(String routineId);
  Future<void> deleteBlocksForRoutine(String routineId);
  Future<List<Map<String, dynamic>>> saveBlocks(List<Map<String, dynamic>> blocksData);
}