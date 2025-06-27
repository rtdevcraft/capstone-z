import 'package:zenigo/src/core/models/user_session.dart';
import 'package:zenigo/src/core/models/user_stats.dart';

abstract class ProgressApi {
  Future<void> addSession(Map<String, dynamic> sessionData);
  Future<List<Map<String, dynamic>>> fetchSessionHistory();
  Stream<List<Map<String, dynamic>>> watchUserProgress();
}