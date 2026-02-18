import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latwa_forma/main.dart';

void main() {
  testWidgets('App builds and shows Łatwa Forma', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LatwaFormaApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Łatwa Forma'), findsWidgets);
  });
}
