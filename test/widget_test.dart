// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:el_moshwar/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ElMoshwarApp());
    await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for splash

    // Verify that our app title is present.
    // Note: It might be on Splash or Home depending on timing/logic.
    // Since we have a splash with 3s delay, pumpAndSettle should take us to Home.
    // Home has 'Welcome to El-Moshwar!'

    expect(find.text('Welcome to El-Moshwar!'), findsOneWidget);
  });
}
