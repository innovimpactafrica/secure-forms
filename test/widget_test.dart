import 'package:flutter_test/flutter_test.dart';
import 'package:quick_forms/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SecureLinkApp());

    // Verify that our counter starts at 0.
    expect(find.text('Secure Link'), findsOneWidget);
  });
}
