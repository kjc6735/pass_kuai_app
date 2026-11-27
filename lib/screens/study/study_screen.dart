import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pass_kuai/components/ui.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/provider/saved_words_provider.dart';
import 'package:pass_kuai/provider/study_service_provider.dart';
import 'package:pass_kuai/provider/tts_service_provider.dart';
import 'package:pass_kuai/router/router.dart';
import 'package:pass_kuai/service/study_service.dart';
import 'package:pass_kuai/theme/app_colors.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  StudySession? _session;
  bool _revealed = false;
  bool _starting = false;

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      final session = await ref.read(studyServiceProvider).start();
      if (!mounted) return;
      setState(() {
        _session = session;
        _revealed = false;
      });
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _answer(bool correct) async {
    final session = _session;
    final word = session?.current;
    if (session == null || word == null) return;

    setState(() {
      session.answer(correct: correct);
      _revealed = false;
    });
    await ref.read(studyServiceProvider).record(word.id, correct: correct);
  }

  void _close() => setState(() => _session = null);

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final inProgress = session != null && !session.isDone;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: '복습',
                trailing: inProgress
                    ? TextButton(onPressed: _close, child: const Text('그만하기'))
                    : null,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: switch (session) {
                  null => _StartView(onStart: _starting ? null : _start),
                  StudySession s when s.isDone => _DoneView(
                    count: s.total,
                    onClose: _close,
                  ),
                  StudySession s => _CardView(
                    session: s,
                    revealed: _revealed,
                    onReveal: () => setState(() => _revealed = true),
                    onAnswer: _answer,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartView extends ConsumerWidget {
  const _StartView({required this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(dueCountProvider).valueOrNull ?? 0;
    final hasWords =
        (ref.watch(savedWordsProvider).valueOrNull ?? const []).isNotEmpty;

    if (due > 0) {
      return MessageView(
        icon: Icons.style_outlined,
        title: '복습할 단어 $due개',
        body: '뜻을 떠올려 보고, 맞혔는지 스스로 골라 주세요.\n몰랐던 단어는 이번 복습 안에서 다시 나와요.',
        action: PrimaryButton(label: '복습 시작', onPressed: onStart),
      );
    }

    if (!hasWords) {
      return MessageView(
        icon: Icons.bookmark_add_outlined,
        title: '아직 저장한 단어가 없어요',
        body: '문장을 분석하고 단어 옆 + 를 누르면\n여기서 복습할 수 있어요.',
        action: PrimaryButton(
          label: '문장 분석하러 가기',
          onPressed: () => context.go(RoutePaths.analyze),
        ),
      );
    }

    return const MessageView(
      icon: Icons.check_circle_outline_rounded,
      title: '오늘 복습할 단어가 없어요',
      body: '복습할 때가 된 단어가 생기면 여기에 나와요.',
    );
  }
}

class _CardView extends ConsumerWidget {
  const _CardView({
    required this.session,
    required this.revealed,
    required this.onReveal,
    required this.onAnswer,
  });

  final StudySession session;
  final bool revealed;
  final VoidCallback onReveal;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = session.current!;
    final progress = session.total == 0
        ? 0.0
        : session.finished / session.total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: progress, minHeight: 10),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${session.finished} / ${session.total}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: AppWeights.label,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                left: 18,
                right: 18,
                top: 18,
                bottom: -10,
                child: _BackCard(color: AppColors.stackBack1),
              ),
              const Positioned(
                left: 9,
                right: 9,
                top: 9,
                bottom: -5,
                child: _BackCard(color: AppColors.stackBack2),
              ),
              Positioned.fill(
                child: AppCard(
                  radius: 28,
                  onTap: revealed ? null : onReveal,
                  padding: const EdgeInsets.all(24),
                  child: _CardFace(word: word, revealed: revealed),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        if (revealed)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onAnswer(false),
                  child: const Text('몰랐어요'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: '알았어요',
                  onPressed: () => onAnswer(true),
                ),
              ),
            ],
          )
        else
          PrimaryButton(label: '뜻 보기', onPressed: onReveal),
        const SizedBox(height: 10),
        const Text(
          '몰랐던 단어는 이번 복습이 끝나기 전에 한 번 더 나와요',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.sub),
        ),
      ],
    );
  }
}

class _BackCard extends StatelessWidget {
  const _BackCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}

class _CardFace extends ConsumerWidget {
  const _CardFace({required this.word, required this.revealed});

  final Word word;
  final bool revealed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syllables = word.syllables;
    final chars = word.word.characters.toList();
    final colored = revealed && syllables.length == chars.length;
    const hanziStyle = TextStyle(
      fontSize: 76,
      fontWeight: AppWeights.hanziLarge,
      color: AppColors.ink,
      height: 1.1,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: colored
              ? Text.rich(
                  TextSpan(
                    children: [
                      for (var i = 0; i < chars.length; i++)
                        TextSpan(
                          text: chars[i],
                          style: hanziStyle.copyWith(
                            color: toneColor(syllables[i].tone),
                          ),
                        ),
                    ],
                  ),
                )
              : Text(word.word, style: hanziStyle),
        ),
        const SizedBox(height: 14),
        if (revealed) ...[
          Text(
            word.pinyin,
            style: TextStyle(
              fontSize: 26,
              fontWeight: AppWeights.pinyin,
              color: syllables.length == 1
                  ? toneColor(syllables.first.tone)
                  : AppColors.ink,
            ),
          ),
          Container(
            width: 48,
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 18),
            color: AppColors.track,
          ),
          Text(
            word.translation,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: AppWeights.label),
          ),
          if (word.pos != null && word.pos!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              word.pos!,
              style: const TextStyle(fontSize: 14, color: AppColors.sub),
            ),
          ],
          const SizedBox(height: 22),
          IconTileButton(
            tooltip: '${word.word} 듣기',
            icon: Icons.volume_up_rounded,
            size: 56,
            onPressed: () => ref.read(ttsServiceProvider).speak(word.word),
          ),
        ] else
          const Text(
            '눌러서 뜻 보기',
            style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.count, required this.onClose});

  final int count;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return MessageView(
      icon: Icons.celebration_outlined,
      title: '오늘 복습 끝!',
      body: '단어 $count개를 복습했어요.',
      action: PrimaryButton(label: '확인', onPressed: onClose),
    );
  }
}
