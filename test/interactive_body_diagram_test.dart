import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivision_app/features/health_timeline/presentation/widgets/interactive_human_body_diagram.dart';

void main() {
  testWidgets('InteractiveHumanBodyDiagram renders all 3 sub-modes cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InteractiveHumanBodyDiagram(),
          ),
        ),
      ),
    );

    // Initial load: Muscle Atlas sub-mode
    expect(find.text('Interactive Human Body'), findsOneWidget);
    expect(find.text('Muscle Atlas'), findsOneWidget);
    expect(find.text('Heatmap'), findsOneWidget);
    expect(find.text('Body Zones'), findsOneWidget);

    // Switch to Heatmap
    await tester.tap(find.text('Heatmap'));
    await tester.pumpAndSettle();
    expect(find.text('Fatigue & Muscle Soreness Heatmap'), findsOneWidget);

    // Switch to Body Zones
    await tester.tap(find.text('Body Zones'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Targeted Areas'), findsOneWidget);
  });
}
