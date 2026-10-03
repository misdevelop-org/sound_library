import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_library_example/main.dart';

void main() {
  testWidgets('filters sounds by category and by search', (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SoundLibraryApp());
    await tester.pump();

    expect(find.text('Click'), findsOneWidget);
    expect(find.text('Add to cart'), findsOneWidget);

    await tester.tap(find.text('Commerce').first);
    await tester.pump();
    expect(find.text('Add to cart'), findsOneWidget);
    expect(find.text('Click'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.enterText(find.byType(TextField), 'cart');
    await tester.pump();
    expect(find.text('Add to cart'), findsOneWidget);
    expect(find.text('Click'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.textContaining('No sounds match'), findsOneWidget);
  });
}
