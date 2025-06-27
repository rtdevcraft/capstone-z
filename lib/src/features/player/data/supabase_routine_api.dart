import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/src/features/player/data/routine_api.dart';

class SupabaseRoutineApi implements RoutineApi {
  final SupabaseClient _client;

  SupabaseRoutineApi(this._client);

  @override
  Future<List<Map<String, dynamic>>> fetchAllRoutines() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      final data = await _client
          .from('routines')
          .select('*, blocks(*)')
          .isFilter('user_id', null)
          .order('created_at', ascending: false);
      return data;
    }

    final data = await _client
        .from('routines')
        .select('*, blocks(*)')
        .or('user_id.eq.$userId,user_id.is.null')
        .order('created_at', ascending: false);
    return data;
  }

  @override
  Future<Map<String, dynamic>?> fetchRoutineById(String id) async {
    final data =
        await _client.from('routines').select().eq('id', id).maybeSingle();
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBlocksForRoutine(
      String routineId) async {
    final data = await _client
        .from('blocks')
        .select()
        .eq('routine_id', routineId)
        .order('block_order', ascending: true);
    return data;
  }

  @override
  Future<Map<String, dynamic>> saveRoutine(
      Map<String, dynamic> routineData) async {
    final data =
        await _client.from('routines').upsert(routineData).select().single();
    return data;
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    await _client.from('routines').delete().eq('id', routineId);
  }

  @override
  Future<void> deleteBlocksForRoutine(String routineId) async {
    await _client.from('blocks').delete().eq('routine_id', routineId);
  }

  @override
  Future<List<Map<String, dynamic>>> saveBlocks(
      List<Map<String, dynamic>> blocksData) async {
    final data = await _client.from('blocks').insert(blocksData).select();
    return data;
  }
}