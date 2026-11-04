import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivision_app/app/app.dart';
import 'package:medivision_app/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('MediVision AI app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MediVisionApp()));

    // Initial frame renders splash screen and brand tagline
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(
      find.text('Intelligent Medical History & Clinical Companion'),
      findsOneWidget,
    );
  });
}
