import 'package:flutter_test/flutter_test.dart';
import 'package:scratch_car/main.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const ScratchCarApp());
    await tester.pump();
    expect(find.text('はじめる！'), findsOneWidget);
  });
}
