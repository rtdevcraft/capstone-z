import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/src/features/progress/data/progress_api.dart';

class SupabaseProgressApi implements ProgressApi {
  final SupabaseClient _client;

  SupabaseProgressApi(this._client);

  @override
  Future<void> addSession(Map<String, dynamic> sessionData) async {
    await _client.from('user_progress').insert(sessionData);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSessionHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client
        .from('user_progress')
        .select('*, routines(title)')
        .eq('user_id', user.id)
        .order('completed_at', ascending: false);
    return data;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchUserProgress() {
    final user = _client.auth.currentUser;
    if (user == null) return Stream.value([]);

    return _client.from('user_progress').stream(primaryKey: ['id']).eq('user_id', user.id);
  }
}