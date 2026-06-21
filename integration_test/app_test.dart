import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:super_app_flutter/app.dart';
import 'package:super_app_flutter/core/di/service_locator.dart' as di;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Flow Test', () {
    testWidgets('Full App Startup and Navigation Test', (tester) async {
      await di.init();

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Super App'), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsWidgets);
    });
  });
}
