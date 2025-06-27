import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zenigo/src/core/models/user_session.dart';
import 'package:zenigo/src/core/models/user_stats.dart';
import 'package:zenigo/src/features/progress/data/progress_repository.dart';

// Provider to fetch all progress data in parallel
final progressDataProvider = FutureProvider<({UserStats userStats, List<UserSession> history})>(
  (ref) async {
    final repo = ref.watch(progressRepositoryProvider);
    final statsFuture = repo.getUserStats();
    final historyFuture = repo.getSessionHistory();

    final (stats, history) = await (statsFuture, historyFuture).wait;
    return (userStats: stats, history: history);
  },
);

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressData = ref.watch(progressDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: progressData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final userStats = data.userStats;
          final history = data.history;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // User Stats Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    value: userStats.dailyStreak.toString(),
                    label: 'Day Streak',
                  ),
                  _StatItem(
                    value: userStats.totalMinutes.toString(),
                    label: 'Total Minutes',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Session History Section
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (history.isEmpty)
                const Center(child: Text('No recent activity.'))
              else
                ...history.map((session) => _SessionHistoryTile(session: session)),
            ],
          );
        },
      ),
    );
  }
}

// A widget for displaying a single user statistic
class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// A widget for displaying a single session in the history list
class _SessionHistoryTile extends StatelessWidget {
  const _SessionHistoryTile({required this.session});
  final UserSession session;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(session.completedAt);
    final duration = '${session.durationInSeconds ~/ 60} min';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(session.routineTitle),
      subtitle: Text(formattedDate),
      trailing: Text(duration),
    );
  }
}