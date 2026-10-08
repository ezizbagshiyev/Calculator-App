import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  testWidgets('calculator displays and performs a basic addition', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('7'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('8'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('15'), findsOneWidget);
  });

  testWidgets('AC resets the calculator', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.tap(find.text('9'));
    await tester.tap(find.text('AC'));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}
