import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pass_kuai/main.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/table/database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 스피너/네트워크 때문에 pumpAndSettle이 안 끝나므로, 조건이 보일 때까지 폴링한다.
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

    // 1) 분석 화면에서 문장 입력 후 분석
    await tester.enterText(find.byType(TextField), '你好');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '분석하기'));

    // 2) 네트워크 응답으로 결과(你好)가 뜰 때까지 대기
    await waitFor(tester, find.text('你好'));

    // 3) 문장 행 탭 → 상세 화면 (루트 네비게이터 push)
    await tester.tap(find.text('你好').first);
    await tester.pumpAndSettle();
    expect(find.text('단어'), findsOneWidget); // 단어 섹션 헤더

    // 4) 문장 저장 (AppBar +)
    await tester.tap(find.byTooltip('문장 저장'));
    await tester.pump(const Duration(milliseconds: 600));

    // 5) 단어 저장 (단어 행의 add 아이콘 — appbar 제외 마지막 = 好)
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump(const Duration(milliseconds: 600));

    // 6) 상세에서 뒤로 → 단어장 탭으로 이동
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('단어장')); // 하단 탭
    await tester.pumpAndSettle();

    // 7) 단어 탭: 저장한 단어(好)가 보이는지
    await waitFor(tester, find.text('好'));

    // 8) 문장 탭으로 전환 → 저장한 문장(你好)이 보이는지
    await tester.tap(find.text('문장'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('你好'));
  });
}
