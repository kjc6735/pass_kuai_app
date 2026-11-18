import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pass_kuai/components/ui.dart';
import 'package:pass_kuai/components/word_row.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/provider/saved_sentence_repository_provider.dart';
import 'package:pass_kuai/provider/saved_word_repository_provider.dart';
import 'package:pass_kuai/provider/tts_provider.dart';
import 'package:pass_kuai/provider/vocab_service_provider.dart';
import 'package:pass_kuai/router/router.dart';
import 'package:pass_kuai/theme/app_colors.dart';

class SentenceDetailScreen extends ConsumerWidget {
  const SentenceDetailScreen({super.key, this.sentence});

  final Object? sentence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = sentence;
    if (data is! SentenceAnalysis) {
      return Scaffold(
        appBar: AppBar(title: const Text('문장 분석')),
        body: const MessageView(icon: Icons.help_outline, title: '문장 정보가 없어요'),
      );
    }

    final syllables = [for (final word in data.words) ...word.syllables];

    return Scaffold(
      appBar: AppBar(
        title: const Text('문장 분석'),
        actions: [
          IconTileButton(
            tooltip: '문장 저장',
            icon: Icons.bookmark_border_rounded,
            style: IconTileStyle.outline,
            onPressed: () async {
              final added = await ref.read(vocabServiceProvider).saveSentence(data);
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
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            radius: 24,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4,
                  runSpacing: 6,
                  children: [
                    for (final s in syllables)
                      PinyinHanzi(hanzi: s.hanzi, pinyin: s.pinyin, color: toneColor(s.tone)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(data.translation, style: const TextStyle(fontSize: 16, color: AppColors.inkSoft)),
                const SizedBox(height: 14),
                const _ToneLegend(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SoftButton(
                  label: '듣기',
                  icon: Icons.volume_up_rounded,
                  onPressed: () => ref.read(ttsServiceProvider).speak(data.sentence),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 7,
                child: PrimaryButton(
                  label: '따라 말해보기',
                  icon: Icons.mic_none_rounded,
                  onPressed: () => context.pushNamed(RouteNames.practice, extra: data.sentence),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('단어', style: TextStyle(fontSize: 17, fontWeight: AppWeights.title)),
              const SizedBox(width: 6),
              Text('${data.words.length}개', style: const TextStyle(fontSize: 13, color: AppColors.sub)),
            ],
          ),
          const SizedBox(height: 10),
          for (final word in data.words) ...[
            _WordRow(word: word),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ToneLegend extends StatelessWidget {
  const _ToneLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final (label, tone) in const [('1성', 1), ('2성', 2), ('3성', 3), ('4성', 4), ('경성', 0)])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: toneColor(tone), shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.sub)),
            ],
          ),
      ],
    );
  }
}

class _WordRow extends ConsumerStatefulWidget {
  final Word word;
  const _WordRow({required this.word});

  @override
  ConsumerState<_WordRow> createState() => _WordRowState();
}

class _WordRowState extends ConsumerState<_WordRow> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final colors = word.syllables.length == word.text.characters.length
        ? [for (final s in word.syllables) toneColor(s.tone)]
        : null;

    return WordRow(
      text: word.text,
      pinyin: word.pinyin,
      meaning: word.meaning,
      pos: word.pos,
      charColors: colors,
      actions: [
        IconTileButton(
          tooltip: '${word.text} 듣기',
          icon: Icons.volume_up_rounded,
          onPressed: () => ref.read(ttsServiceProvider).speak(word.text),
        ),
        IconTileButton(
          tooltip: _saved ? '${word.text} 단어장에 있음' : '${word.text} 단어장에 저장',
          icon: _saved ? Icons.check_rounded : Icons.add,
          style: _saved ? IconTileStyle.filled : IconTileStyle.outline,
          onPressed: () async {
            final added = await ref.read(vocabServiceProvider).saveWord(word);
            if (added) ref.invalidate(savedWordsProvider);
            if (!context.mounted) return;
            setState(() => _saved = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(added ? '단어장에 저장했어요.' : '이미 단어장에 있어요.'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }
}
