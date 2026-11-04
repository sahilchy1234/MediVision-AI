import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/app/app.dart';
import 'package:medivision_app/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  testWidgets('MediVision app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MediVisionApp()));
    await tester.pumpAndSettle();

    // Initial frame renders home dashboard
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Patient Overview'), findsOneWidget);
  });
}
