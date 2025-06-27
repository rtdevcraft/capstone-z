import 'package:equatable/equatable.dart';

/// Represents a single completed routine session by a user.
class UserSession extends Equatable {
  const UserSession({
    required this.routineId,
    required this.routineTitle,
    required this.completedAt,
    required this.durationInSeconds,
  });

  /// The ID of the routine that was completed.
  final String routineId;

  /// The title of the routine, stored for easy display in history.
  final String routineTitle;

  /// The timestamp when the session was completed.
  final DateTime completedAt;

  /// The total duration of the session in seconds.
  final int durationInSeconds;

  @override
  List<Object?> get props => [routineId, routineTitle, completedAt, durationInSeconds];
}