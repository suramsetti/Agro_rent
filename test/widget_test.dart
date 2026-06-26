// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:f_pro/main.dart';
import 'package:f_pro/services/auth_service.dart';
import 'package:f_pro/services/database_service.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    final box = await Hive.openBox('test_agro_rent');

    // Build our app and trigger a frame.
    final state = AppState(box);
    await state.initialize();
    final auth = AuthService();

    await tester.pumpWidget(AgroRentApp(state: state, auth: auth));
    await tester.pumpAndSettle();

    // Verify that login screen is shown (when not logged in)
    expect(find.text('Login'), findsOneWidget);
  });
}
