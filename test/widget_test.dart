import 'package:flutter_test/flutter_test.dart';
import 'package:elite_app/main.dart';

void main() {
  testWidgets('App renders login screen without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const EliteApp());
    expect(find.text('ELITE IT'), findsWidgets);
  });
}
