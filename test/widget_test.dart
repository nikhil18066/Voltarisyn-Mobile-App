import 'package:flutter_test/flutter_test.dart';
import 'package:voltarisyn_app/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const VoltarisynApp());
    expect(find.text('Voltarisyn'), findsOneWidget);
  });
}
