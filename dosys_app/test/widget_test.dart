import 'package:flutter_test/flutter_test.dart';
import 'package:dosys_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DosysApp());
    expect(find.byType(DosysApp), findsOneWidget);
  });
}
