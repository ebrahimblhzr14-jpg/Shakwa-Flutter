import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shakwa_app/app/app.dart';
import 'package:shakwa_app/data/mock_data/mock_database.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Ensure mock DB is initialized
    MockDatabase.instance.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ShakwaApp()));

    // Allow mock repository timer (300ms) and animations to settle
    await tester.pumpAndSettle();

    // Verify that the app builds without crashing and renders ShakwaApp
    expect(find.byType(ShakwaApp), findsOneWidget);
  });
}
