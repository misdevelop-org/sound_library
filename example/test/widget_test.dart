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

  testWidgets('toggles between light and dark mode', (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SoundLibraryApp());
    await tester.pump();

    // Tests run with a light platform brightness.
    expect(find.byTooltip('Dark mode'), findsOneWidget);
    await tester.tap(find.byTooltip('Dark mode'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byTooltip('Light mode'), findsOneWidget);
    expect(Theme.of(tester.element(find.byType(Scaffold))).brightness, Brightness.dark);
  });
}
