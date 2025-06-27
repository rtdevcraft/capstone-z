import 'package:zenigo/src/core/models/routine_category.dart';

final List<Map<String, dynamic>> seedRoutines = [
  {
    'id': 'mindful-morning-starter',
    'title': 'Mindful Morning Starter',
    'description': 'A gentle start to your day to cultivate presence and calm.',
    'category': RoutineCategory.mindfulMorning.name,
    'blocks': [
      {'instruction': 'Begin in a comfortable seated position. Rest your hands on your knees.', 'duration': 10},
      {'instruction': 'Close your eyes and take three deep, cleansing breaths. Inhale through your nose, exhale through your mouth.', 'duration': 15},
      {'instruction': 'Notice the sensation of the air entering and leaving your body.', 'duration': 20},
      {'instruction': 'Gently scan your body from head to toe, releasing any tension you find.', 'duration': 25},
      {'instruction': 'Set a simple intention for your day. Carry this feeling with you.', 'duration': 10},
    ]
  },
  {
    'id': '5-minute-focus-boost',
    'title': '5-Minute Focus Boost',
    'description': 'A quick routine to sharpen your mind and improve concentration before a task.',
    'category': RoutineCategory.focusClarity.name,
    'blocks': [
      {'instruction': 'Sit upright in your chair, feet flat on the floor.', 'duration': 5},
      {'instruction': 'Focus your gaze on a single point in front of you.', 'duration': 20},
      {'instruction': 'Breathe in for 4 counts, hold for 4, and exhale for 4. Repeat.', 'duration': 40},
      {'instruction': 'Bring your attention to your immediate task. What is the first small step?', 'duration': 10},
      {'instruction': 'You are ready to begin. Start now.', 'duration': 5},
    ]
  },
  {
    'id': 'evening-wind-down',
    'title': 'Evening Wind-Down',
    'description': 'Release the day and prepare your mind for restful sleep.',
    'category': RoutineCategory.eveningWindDown.name,
    'blocks': [
      {'instruction': 'Lie down comfortably on your back. Let your body feel heavy.', 'duration': 15},
      {'instruction': 'Tense and release your toes. Then your calves. Then your thighs.', 'duration': 30},
      {'instruction': 'Continue this progressive relaxation up through your torso, arms, and face.', 'duration': 60},
      {'instruction': 'Recall one positive moment from your day. Hold it in your mind.', 'duration': 20},
      {'instruction': 'Breathe deeply and let go. Sleep is near.', 'duration': 15},
    ]
  },
  {
    'id': 'neck-and-shoulder-relief',
    'title': 'Neck & Shoulder Relief',
    'description': 'A short sequence to alleviate tension in the neck and shoulders from sitting.',
    'category': RoutineCategory.targetedRelief.name,
    'blocks': [
      {'instruction': 'While seated, gently drop your right ear towards your right shoulder. Hold.', 'duration': 20},
      {'instruction': 'Slowly roll your chin to your chest, then bring your left ear to your left shoulder. Hold.', 'duration': 20},
      {'instruction': 'Return to center. Shrug your shoulders up to your ears, then release them down completely.', 'duration': 15},
      {'instruction': 'Gently clasp your hands behind your back and straighten your arms to open your chest.', 'duration': 20},
      {'instruction': 'Release and feel the new space you\'ve created.', 'duration': 5},
    ]
  },
];