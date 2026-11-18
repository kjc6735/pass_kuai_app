import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pass_kuai/components/sentence_row.dart';
import 'package:pass_kuai/components/word_row.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/provider/saved_sentence_repository_provider.dart';
import 'package:pass_kuai/provider/saved_word_repository_provider.dart';
import 'package:pass_kuai/provider/sentence_words_repository.provider.dart';
import 'package:pass_kuai/provider/tts_provider.dart';
import 'package:pass_kuai/router/router.dart';

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
      appBar: AppBar(
        centerTitle: false,
        title: const Text('단어장', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          // 상단: 단어 / 문장 선택
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: _VocabTabSelector(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
          ),
          // 본문: 선택한 탭의 리스트
          Expanded(
            child: _tab == _VocabTab.word
                ? const _SavedWordList()
                : const _SavedSentenceList(),
          ),
        ],
      ),
    );
  }
}

/// 단어 / 문장 전환용 심플한 세그먼트 토글.
/// 연한 회색 트랙 위에서 선택된 항목만 흰색 알약으로 부드럽게 슬라이드한다.
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
        color: const Color(0xFFF2F2F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              // 슬라이딩 알약 인디케이터
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
              color: isSelected
                  ? const Color(0xFF111111)
                  : Colors.grey.shade500,
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
          return const _EmptyState(text: '저장한 단어가 없어요.');
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savedWordsProvider),
          child: ListView.separated(
            itemCount: words.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final w = words[i];
              return WordRow(
                text: w.word,
                pinyin: w.pinyin,
                meaning: w.translation,
                pos: w.pos,
                actions: [
                  SquareIconButton(
                    icon: Icons.play_arrow,
                    onPressed: () =>
                        ref.read(ttsServiceProvider).speak(w.word),
                  ),
                  SquareIconButton(
                    icon: Icons.delete_outline,
                    onPressed: () async {
                      // 낙관적: 화면에서 즉시 사라지고, 백그라운드로 삭제
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

/// 저장한 문장 리스트
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
          return const _EmptyState(text: '저장한 문장이 없어요.');
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savedSentencesProvider),
          child: ListView.separated(
            itemCount: sentences.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = sentences[i];
              return SentenceRow(
                sentence: s.sentence,
                translation: s.translation,
                onTap: () async {
                  // 저장된 문장의 단어 분석(SentenceWords→Words)을 모아 재구성해서 전달
                  final words = await ref
                      .read(sentenceWordsRepositoryProvider)
                      .findWordsBySentence(s.id);
                  final analysis = SentenceAnalysis(
                    sentence: s.sentence,
                    translation: s.translation,
                    words: words.map((w) {
                      final syl = (jsonDecode(w.syllables) as List)
                          .map(
                            (e) =>
                                Syllable.fromJson(e as Map<String, dynamic>),
                          )
                          .toList();
                      return Word(
                        text: w.word,
                        pinyin: w.pinyin,
                        meaning: w.translation,
                        pos: w.pos,
                        syllables: syl,
                      );
                    }).toList(),
                  );
                  if (!context.mounted) return;
                  context.pushNamed(
                    RouteNames.sentenceDetail,
                    extra: analysis,
                  );
                },
                actions: [
                  SquareIconButton(
                    icon: Icons.delete_outline,
                    onPressed: () async {
                      // 낙관적: 화면에서 즉시 사라지고, 백그라운드로 삭제
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
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '불러오기 실패: $message',
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
