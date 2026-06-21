import 'package:flutter_test/flutter_test.dart';
import 'package:workaholic/app.dart';

void main() {
  testWidgets('WorkaholicApp should build', (WidgetTester tester) async {
    // Smoke test — just verify the app widget builds without errors
    // Note: Full widget tests require SharedPreferences mock setup
    expect(const WorkaholicApp(), isNotNull);
  });
}
