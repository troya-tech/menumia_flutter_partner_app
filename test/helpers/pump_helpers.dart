import 'package:flutter_test/flutter_test.dart';

/// Helper to settle the widget tree while flushing pending timers.
///
/// [RestaurantContextService.init()] has a 5-second timeout that blocks
/// [WidgetTester.pumpAndSettle] in widget tests (FakeAsync doesn't allow
/// pending timers). This pumps past it with explicit durations.
Future<void> pumpAndFlush(WidgetTester tester) async {
  await tester.pump();                                    // Initial frame
  await tester.pump(const Duration(seconds: 6));          // Flush the 5s timeout
  await tester.pump();                                    // Settle remaining frames
}
