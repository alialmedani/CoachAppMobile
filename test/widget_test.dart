// Phase-0 placeholder smoke test.
//
// The default counter test was removed with the counter demo. Real widget
// tests are added per feature slice (and consolidated in Phase 20 via
// mobile-tester) — building the full `CoachApp` here would require booting
// EasyLocalization + Hive (CacheHelper) + ScreenUtil, which belongs in the
// feature tests, not this smoke slot.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test harness renders a MaterialApp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('CoachApp'))),
    );

    expect(find.text('CoachApp'), findsOneWidget);
  });
}
