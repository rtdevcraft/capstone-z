import 'package:equatable/equatable.dart';

/// A data model to hold user statistics like streak and total minutes.
class UserStats extends Equatable {
  const UserStats({
    required this.dailyStreak,
    required this.totalMinutes,
  });

  /// The user's current consecutive daily session streak.
  final int dailyStreak;

  /// The user's lifetime total minutes of practice.
  final int totalMinutes;

  @override
  List<Object?> get props => [dailyStreak, totalMinutes];
}