import 'package:flutter_test/flutter_test.dart';

import 'package:appmusic/main.dart';

void main() {
  testWidgets('App starts with home shell', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Offline Music'), findsOneWidget);
  });
}
