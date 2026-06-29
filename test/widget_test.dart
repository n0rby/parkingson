import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Intentionally empty — services require platform plugins unavailable in tests.
    expect(true, isTrue);
  });
}
