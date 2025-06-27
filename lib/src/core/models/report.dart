import 'package:flutter/material.dart';

@immutable
class Report {
  const Report({
    required this.id,
    required this.title,
    required this.dateRange,
    required this.rows,
  });

  final String id;
  final String title;
  final DateTimeRange dateRange;
  final List<UserSessionRow> rows;
}

@immutable
class UserSessionRow {
  const UserSessionRow({
    required this.routineTitle,
    required this.completedAt,
    required this.duration,
  });

  final String routineTitle;
  final DateTime completedAt;
  final Duration duration;
}