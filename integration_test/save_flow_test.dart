import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pass_kuai/main.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/database/database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('시간 초과: $finder 를 찾지 못함');
  }

  testWidgets('분석 → 단어/문장 저장 → 단어장에 표시', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [dbProvider.overrideWithValue(db)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '你好');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '분석하기'));

    await waitFor(tester, find.text('你好'));

    await tester.tap(find.text('你好').first);
    await tester.pumpAndSettle();
    expect(find.text('단어'), findsOneWidget);

    await tester.tap(find.byTooltip('문장 저장'));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump(const Duration(milliseconds: 600));

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('단어장'));
    await tester.pumpAndSettle();

    await waitFor(tester, find.text('好'));

    await tester.tap(find.text('문장'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('你好'));
  });
}
