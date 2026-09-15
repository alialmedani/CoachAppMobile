import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests for [UnsavedChangesGuard] — the create/edit back-navigation
/// guard added in the P18 hardening pass. Verifies the three exit paths:
/// clean back leaves immediately, a dirty back is intercepted with a confirm,
/// "keep editing" stays, "discard" leaves.
void main() {
  // Pushes a guarded editor route on top of a home page.
  Widget host({required bool Function() isDirty}) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => UnsavedChangesGuard(
                    isDirty: isDirty,
                    child: Scaffold(
                      appBar: AppBar(title: const Text('Editor')),
                      body: const Center(child: Text('editor-body')),
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('editor-body'), findsOneWidget);
  }

  // The confirm dialog has exactly two actions: [keep editing, discard].
  Finder dialogButtons() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextButton),
  );

  testWidgets('clean back pops immediately with no confirm', (tester) async {
    await tester.pumpWidget(host(isDirty: () => false));
    await openEditor(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('editor-body'), findsNothing); // left the editor
  });

  testWidgets('dirty back is intercepted with a confirm dialog', (tester) async {
    await tester.pumpWidget(host(isDirty: () => true));
    await openEditor(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    // still on the editor while the dialog is up
    expect(find.text('editor-body'), findsOneWidget);
  });

  testWidgets('"keep editing" dismisses the dialog and stays', (tester) async {
    await tester.pumpWidget(host(isDirty: () => true));
    await openEditor(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(dialogButtons().first); // keep editing
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('editor-body'), findsOneWidget); // still editing
  });

  testWidgets('"discard" leaves the editor', (tester) async {
    await tester.pumpWidget(host(isDirty: () => true));
    await openEditor(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(dialogButtons().last); // discard
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('editor-body'), findsNothing); // left the editor
  });
}
