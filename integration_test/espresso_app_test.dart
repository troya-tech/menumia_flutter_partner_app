import 'package:flutter_test/flutter_test.dart';
import 'package:espresso/espresso.dart';
import 'package:integration_test/integration_test.dart';
import 'package:menumia_flutter_partner_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Espresso Login Test', (WidgetTester tester) async {
    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // Use Espresso matchers
    // For example, find a widget with a specific text and click it
    // Note: Espresso is primarily for native views or when you need native-level interaction.
    // For pure Flutter widgets, standard flutter_test matches are usually enough.
    // But this shows how to bridge them.
    
    // Example Espresso call:
    // onWidget(withText('Login with Google')).perform(click());
    
    expect(find.text('Login with Google'), findsOneWidget);
  });
}
