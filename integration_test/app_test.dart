import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:super_app_flutter/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Flow Test', () {
    testWidgets('Full App Startup and Navigation Test', (tester) async {
      // Start the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Check if WelcomePage is displayed
      expect(find.text('Welcome to Super App'), findsOneWidget);

      // Click 'Get Started'
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Check if LoginPage is displayed
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
