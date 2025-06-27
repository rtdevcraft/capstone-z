/// Represents the categories for wellness routines.
enum RoutineCategory {
  all('All'),
  mindfulMorning('Mindful Morning'),
  eveningWindDown('Evening Wind-Down'),
  targetedRelief('Targeted Relief'),
  focusClarity('Focus & Clarity'),
  dailyPick('Daily Pick');

  const RoutineCategory(this.displayName);
  final String displayName;
}