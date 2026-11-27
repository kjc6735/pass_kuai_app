import 'dart:async';

import 'package:drift/drift.dart' show InvalidDataException;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/provider/vocab_service_provider.dart';
import 'package:pass_kuai/screens/analyze/sentence_detail_screen.dart';
import 'package:pass_kuai/service/vocab_service.dart';

class _SlowVocabService extends Fake implements VocabService {
  final sentenceGate = Completer<bool>();
  final wordGate = Completer<bool>();
  int sentenceCalls = 0;
  int wordCalls = 0;

  @override
  Future<bool> saveSentence(SentenceAnalysis analysis) {
    sentenceCalls++;
    return sentenceGate.future;
  }

  @override
  Future<bool> saveWord(WordAnalysis word) {
    wordCalls++;
    return wordGate.future;
  }
}

void main() {
  const analysis = SentenceAnalysis(
    sentence: '你好',
    translation: '안녕',
    words: [
      WordAnalysis(text: '你好', pinyin: 'nǐhǎo', meaning: '안녕', syllables: []),
    ],
  );

  Future<_SlowVocabService> pump(WidgetTester tester) async {
    final fake = _SlowVocabService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vocabServiceProvider.overrideWithValue(fake)],
        child: const MaterialApp(
          home: SentenceDetailScreen(sentence: analysis),
        ),
      ),
    );
    return fake;
  }

  testWidgets('문장 저장 버튼은 저장 중 연타해도 한 번만 요청한다', (tester) async {
    final fake = await pump(tester);
    final button = find.byIcon(Icons.bookmark_border_rounded);

    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.tap(button);
    await tester.pump();
    expect(fake.sentenceCalls, 1);

    fake.sentenceGate.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('문장을 단어장에 저장했어요.'), findsOneWidget);

    // 저장이 끝나면 다시 누를 수 있다.
    await tester.tap(button);
    await tester.pump();
    expect(fake.sentenceCalls, 2);
  });

  testWidgets('단어 저장 버튼은 저장 중 연타해도 한 번만 요청한다', (tester) async {
    final fake = await pump(tester);
    final button = find.byIcon(Icons.add);

    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();
    expect(fake.wordCalls, 1);

    fake.wordGate.complete(true);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('문장 저장이 실패하면 안내하고 버튼을 다시 켠다', (tester) async {
    final fake = await pump(tester);
    final button = find.byIcon(Icons.bookmark_border_rounded);

    await tester.tap(button);
    await tester.pump();
    fake.sentenceGate.completeError(InvalidDataException('too long'));
    await tester.pumpAndSettle();

    expect(find.text('내용이 너무 길거나 비어 있어서 저장하지 못했어요.'), findsOneWidget);
    expect(find.text('문장을 단어장에 저장했어요.'), findsNothing);

    await tester.tap(button);
    await tester.pump();
    expect(fake.sentenceCalls, 2);
  });

  testWidgets('단어 저장이 실패하면 안내하고 체크 상태로 바꾸지 않는다', (tester) async {
    final fake = await pump(tester);
    final button = find.byIcon(Icons.add);

    await tester.tap(button);
    await tester.pump();
    fake.wordGate.completeError(StateError('db closed'));
    await tester.pumpAndSettle();

    expect(find.text('저장하지 못했어요. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    // 버튼이 다시 켜져 재시도할 수 있다.
    await tester.tap(button);
    await tester.pump();
    expect(fake.wordCalls, 2);
  });
}
