import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pass_kuai/components/sentence_row.dart';
import 'package:pass_kuai/components/ui.dart';
import 'package:pass_kuai/components/word_row.dart';
import 'package:pass_kuai/provider/saved_sentences_provider.dart';
import 'package:pass_kuai/provider/saved_words_provider.dart';
import 'package:pass_kuai/provider/sentence_service_provider.dart';
import 'package:pass_kuai/provider/tts_service_provider.dart';
import 'package:pass_kuai/router/router.dart';
import 'package:pass_kuai/theme/app_colors.dart';

enum _VocabTab { word, sentence }

class VocabScreen extends ConsumerStatefulWidget {
  const VocabScreen({super.key});

  @override
  ConsumerState<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends ConsumerState<VocabScreen> {
  _VocabTab _tab = _VocabTab.word;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: PageHeader(subtitle: '모아 둔 표현', title: '단어장'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _VocabTabSelector(
                selected: _tab,
                onChanged: (tab) => setState(() => _tab = tab),
              ),
            ),
            Expanded(
              child: _tab == _VocabTab.word
                  ? const _SavedWordList()
                  : const _SavedSentenceList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VocabTabSelector extends StatelessWidget {
  final _VocabTab selected;
  final ValueChanged<_VocabTab> onChanged;

  const _VocabTabSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.segmentTrack,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: selected == _VocabTab.word
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: halfWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: cardShadow,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildSegment(_VocabTab.word, '단어'),
                  _buildSegment(_VocabTab.sentence, '문장'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegment(_VocabTab tab, String label) {
    final isSelected = selected == tab;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(tab),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryText : AppColors.sub,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _SavedWordList extends ConsumerWidget {
  const _SavedWordList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWords = ref.watch(savedWordsProvider);

    return asyncWords.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: '$e'),
      data: (words) {
        if (words.isEmpty) {
          return const _EmptyState(
            icon: Icons.bookmark_add_outlined,
            title: '저장한 단어가 없어요',
            body: '문장 분석에서 단어 옆 + 를 눌러 모아 보세요.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savedWordsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: words.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final w = words[i];
              return WordRow(
                text: w.word,
                pinyin: w.pinyin,
                meaning: w.translation,
                pos: w.pos,
                actions: [
                  SquareIconButton(
                    icon: Icons.volume_up_rounded,
                    tooltip: '${w.word} 듣기',
                    onPressed: () => ref.read(ttsServiceProvider).speak(w.word),
                  ),
                  SquareIconButton(
                    icon: Icons.delete_outline,
                    tooltip: '${w.word} 삭제',
                    style: IconTileStyle.outline,
                    onPressed: () async {
                      try {
                        await ref
                            .read(savedWordsProvider.notifier)
                            .remove(w.id);
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('삭제 실패 — 복구했어요.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SavedSentenceList extends ConsumerWidget {
  const _SavedSentenceList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSentences = ref.watch(savedSentencesProvider);

    return asyncSentences.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: '$e'),
      data: (sentences) {
        if (sentences.isEmpty) {
          return const _EmptyState(
            icon: Icons.bookmark_border_rounded,
            title: '저장한 문장이 없어요',
            body: '문장 분석 화면 오른쪽 위 책갈피로 저장할 수 있어요.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savedSentencesProvider),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: sentences.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = sentences[i];
              return SentenceRow(
                sentence: s.sentence,
                translation: s.translation,
                onTap: () async {
                  final analysis = await ref
                      .read(sentenceServiceProvider)
                      .loadAnalysis(s);
                  if (!context.mounted) return;
                  context.pushNamed(RouteNames.sentenceDetail, extra: analysis);
                },
                actions: [
                  SquareIconButton(
                    icon: Icons.delete_outline,
                    tooltip: '문장 삭제',
                    style: IconTileStyle.outline,
                    onPressed: () async {
                      try {
                        await ref
                            .read(savedSentencesProvider.notifier)
                            .remove(s.id);
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('삭제 실패 — 복구했어요.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return MessageView(icon: icon, title: title, body: body);
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return MessageView(
      icon: Icons.error_outline_rounded,
      title: '불러오지 못했어요',
      body: message,
    );
  }
}
