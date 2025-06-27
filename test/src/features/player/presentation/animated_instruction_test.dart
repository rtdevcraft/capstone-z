import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenigo/src/features/player/presentation/animated_instruction.dart';

void main() {
  group('AnimatedInstruction', () {
    testWidgets('displays the initial instruction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedInstruction(
              instruction: 'Test Instruction',
              duration: Duration(seconds: 1),
            ),
          ),
        ),
      );

      expect(find.text('Test Instruction'), findsOneWidget);
    });

    testWidgets('animation progresses over time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedInstruction(
              instruction: 'Test Instruction',
              duration: Duration(seconds: 1),
            ),
          ),
        ),
      );

      // At the beginning, opacity is 1.0
      var opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, closeTo(1.0, 0.01));

      // Halfway through the animation
      await tester.pump(const Duration(milliseconds: 500));
      opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, closeTo(0.6, 0.01)); // 1.0 - (0.5 * 0.8) = 0.6

      // At the end of the animation
      await tester.pump(const Duration(milliseconds: 500));
      opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, closeTo(0.2, 0.01)); // 1.0 - (1.0 * 0.8) = 0.2
    });

    testWidgets('restarts animation when instruction changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedInstruction(
              instruction: 'First',
              duration: Duration(seconds: 1),
            ),
          ),
        ),
      );

      // Let the first animation finish
      await tester.pumpAndSettle();
      var opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, closeTo(0.2, 0.01));

      // Change the instruction
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedInstruction(
              instruction: 'Second',
              duration: Duration(seconds: 1),
            ),
          ),
        ),
      );

      // The animation should have restarted, so opacity is back to 1.0
      opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(find.text('Second'), findsOneWidget);
      expect(opacity.opacity, closeTo(1.0, 0.01));
    });
  });
}