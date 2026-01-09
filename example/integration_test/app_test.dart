import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_device_state_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('VPN Detection Integration Tests', () {
    testWidgets('Full app flow', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Verify initial UI
      expect(find.text('VPN Status'), findsOneWidget);

      // Wait for VPN check
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify status displayed
      expect(find.textContaining('VPN is'), findsOneWidget);

      // Tap refresh button
      await tester.tap(find.text('Check Again'));
      await tester.pumpAndSettle();

      // Verify still works
      expect(find.textContaining('VPN is'), findsOneWidget);
    });

    testWidgets('Real-time monitoring works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Get initial state
      final initialText = find.textContaining('VPN is');
      expect(initialText, findsOneWidget);

      // Wait for potential state changes
      await tester.pump(Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify still showing status
      expect(find.textContaining('VPN is'), findsOneWidget);
    });
  });
}
