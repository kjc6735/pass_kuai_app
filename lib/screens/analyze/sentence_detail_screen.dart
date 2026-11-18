import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/components/word_row.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/provider/saved_sentence_repository_provider.dart';
import 'package:pass_kuai/provider/saved_word_repository_provider.dart';
import 'package:pass_kuai/provider/tts_provider.dart';
import 'package:pass_kuai/provider/vocab_service_provider.dart';

Color toneColor(int tone) {
  switch (tone) {
    case 1:
      return const Color(0xFFE53935); // 빨강
    case 2:
      return const Color(0xFFFB8C00); // 주황
    case 3:
      return const Color(0xFF1E88E5); // 파랑
    case 4:
      return const Color(0xFF8E24AA); // 보라
    default:
      return const Color(0xFF9E9E9E); // 경성
  }
}

class SentenceDetailScreen extends ConsumerWidget {
  const SentenceDetailScreen({super.key, this.sentence});

  final Object? sentence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = sentence;
    if (data is! SentenceAnalysis) {
      return Scaffold(
        appBar: AppBar(title: const Text('문장 분석')),
        body: const Center(child: Text('문장 정보가 없습니다.')),
      );
    }

    final syllables = [for (final word in data.words) ...word.syllables];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '문장 분석',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: '문장 저장',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await ref
                  .read(vocabServiceProvider)
                  .saveSentence(data);
              if (added) ref.invalidate(savedSentencesProvider);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(added ? '문장을 단어장에 저장했어요.' : '이미 단어장에 있어요.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 병음 + 한자 (성조 색상)
          Wrap(
            spacing: 4,
            runSpacing: 8,
            children: [
              for (final s in syllables)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.hanzi,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: toneColor(s.tone),
                      ),
                    ),
                    Text(
                      s.pinyin,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: toneColor(s.tone),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            data.translation,
            style: const TextStyle(color: Colors.black, fontSize: 17),
          ),
          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: () => ref.read(ttsServiceProvider).speak(data.sentence),
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              '문장 듣기',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 단어 섹션
          const Text(
            '단어',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < data.words.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE0E0E0)),
            _WordRow(word: data.words[i]),
          ],
        ],
      ),
    );
  }
}

class _WordRow extends ConsumerWidget {
  final Word word;
  const _WordRow({required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WordRow(
      text: word.text,
      pinyin: word.pinyin,
      meaning: word.meaning,
      pos: word.pos,
      actions: [
        SquareIconButton(
          icon: Icons.play_arrow,
          onPressed: () => ref.read(ttsServiceProvider).speak(word.text),
        ),
        SquareIconButton(
          icon: Icons.add,
          onPressed: () async {
            final added = await ref.read(vocabServiceProvider).saveWord(word);
            if (added) ref.invalidate(savedWordsProvider);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(added ? '단어장에 추가했습니다.' : '이미 단어장에 있습니다.'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }
}
