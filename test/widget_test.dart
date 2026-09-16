import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapdakhata/app.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KapdaKhataApp()),
    );
    await tester.pump();

    expect(find.text('KapdaKhata'), findsOneWidget);
    expect(find.text('Manage • Sell • Grow'), findsOneWidget);

    // Flush the splash navigation timer so the test harness can exit cleanly.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
