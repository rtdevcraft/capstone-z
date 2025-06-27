
abstract class ProgressApi {
  Future<void> addSession(Map<String, dynamic> sessionData);
  Future<List<Map<String, dynamic>>> fetchSessionHistory();
  Stream<List<Map<String, dynamic>>> watchUserProgress();
}