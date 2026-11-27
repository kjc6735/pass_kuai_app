import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/provider/study_service_provider.dart';
import 'package:pass_kuai/provider/today_provider.dart';

void main() {
  group('todayProvider', () {
    testWidgets('자정이 지나면 타이머로 다음 날로 바뀐다', (tester) async {
      var now = DateTime(2026, 11, 19, 23, 50);
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(todayProvider, (_, _) {});

      expect(sub.read(), DateTime(2026, 11, 19));

      now = DateTime(2026, 11, 19, 23, 59);
      await tester.pump(const Duration(minutes: 9));
      expect(sub.read(), DateTime(2026, 11, 19));

      now = DateTime(2026, 11, 20, 0, 0);
      await tester.pump(const Duration(minutes: 1));
      expect(sub.read(), DateTime(2026, 11, 20));

      // 다음 자정 타이머도 다시 걸린다.
      now = DateTime(2026, 11, 21, 0, 0);
      await tester.pump(const Duration(days: 1));
      expect(sub.read(), DateTime(2026, 11, 21));
    });

    testWidgets('타이머가 일찍 울려도 날짜가 안 바뀌었으면 그대로 두고 다시 건다', (tester) async {
      var now = DateTime(2026, 11, 19, 23, 50);
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(todayProvider, (_, _) {});

      // 기기 시간을 되돌린 상황: 타이머가 울릴 때 아직 전날이다.
      now = DateTime(2026, 11, 19, 23, 0);
      await tester.pump(const Duration(minutes: 10));
      expect(sub.read(), DateTime(2026, 11, 19));

      now = DateTime(2026, 11, 20, 0, 0);
      await tester.pump(const Duration(hours: 1));
      expect(sub.read(), DateTime(2026, 11, 20));
    });

    testWidgets('refresh는 타이머를 기다리지 않고 바뀐 날짜를 반영한다', (tester) async {
      var now = DateTime(2026, 11, 19, 10);
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(todayProvider, (_, _) {});

      // 백그라운드에서 타이머가 멈춰 있다가 이틀 뒤 foreground로 돌아온 상황.
      now = DateTime(2026, 11, 21, 8);
      container.read(todayProvider.notifier).refresh();
      expect(sub.read(), DateTime(2026, 11, 21));
    });
  });

  test('날짜가 바뀌면 dueCountProvider가 새 기준일로 다시 센다', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    var now = DateTime(2026, 11, 19, 23, 50);
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    final id = await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(word: '你', translation: '너', pinyin: 'ni'),
        );
    await db
        .into(db.savedWords)
        .insert(
          SavedWordsCompanion(
            wordId: Value(id),
            nextReviewAt: Value(DateTime(2026, 11, 20, 9)),
          ),
        );

    container.listen(dueCountProvider, (_, _) {});
    expect(await container.read(dueCountProvider.future), 0);

    // DB는 그대로, 시간만 다음 날로 넘어감.
    now = DateTime(2026, 11, 20, 0, 1);
    container.read(todayProvider.notifier).refresh();
    expect(await container.read(dueCountProvider.future), 1);
  });
}
