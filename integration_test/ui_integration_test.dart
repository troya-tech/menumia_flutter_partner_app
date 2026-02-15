import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:menumia_flutter_partner_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UI Integration Test', (WidgetTester tester) async {
    // Start the app
    await app.main();
    
    // Wait for the app to settle
    await tester.pumpAndSettle();

    // The app might show a loading screen or splash screen first
    // Let's wait for the "Menumia Partner" title which is on the LoginPage
    // We'll use a finder that waits
    final titleFinder = find.text('Menumia Partner');
    
    // Custom wait loop if pumpAndSettle didn't catch it
    bool found = false;
    for (int i = 0; i < 10; i++) {
        if (tester.any(titleFinder)) {
            found = true;
            break;
        }
        await tester.pump(const Duration(milliseconds: 500));
    }

    if (!found) {
        debugPrint('Title not found. Current widgets:');
        for (final widget in tester.allWidgets) {
            debugPrint(widget.toString());
        }
    }

    expect(find.text('Menumia Partner'), findsOneWidget);
    expect(find.text('Login with Google'), findsOneWidget);
  });
}
