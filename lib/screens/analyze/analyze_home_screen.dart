import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pass_kuai/api/api_error.dart';
import 'package:pass_kuai/components/sentence_row.dart';
import 'package:pass_kuai/components/ui.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/provider/analyze_repository_provider.dart';
import 'package:pass_kuai/provider/study_service_provider.dart';
import 'package:pass_kuai/theme/app_colors.dart';

import '../../router/router.dart';

class AnalyzeHomeScreen extends ConsumerStatefulWidget {
  const AnalyzeHomeScreen({super.key});

  @override
  ConsumerState<AnalyzeHomeScreen> createState() => _AnalyzeHomeScreenState();
}

class _AnalyzeHomeScreenState extends ConsumerState<AnalyzeHomeScreen> {
  static const _maxInputLength = 1000;

  final _controller = TextEditingController();
  bool _isLoading = false;

  AnalyzeResult _analyzeResult = const AnalyzeResult(sentences: []);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(analyzeRepositoryProvider);
      final result = await repo.analyzeSentence(sentence: text);
      if (!mounted) return;
      setState(() => _analyzeResult = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentences = _analyzeResult.sentences;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const PageHeader(
                subtitle: '오늘도 한 문장씩',
                title: '문장 분석',
                trailing: _LogoTile(),
              ),
              const SizedBox(height: 16),
              const _DueCard(),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '중국어 문장을 붙여넣어 보세요',
                      style: TextStyle(fontSize: 15, fontWeight: AppWeights.label),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      minLines: 4,
                      maxLines: 8,
                      maxLength: _maxInputLength,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(fontSize: 18, color: AppColors.ink),
                      decoration: const InputDecoration(hintText: '예) 我想喝一杯咖啡'),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, value, _) => PrimaryButton(
                        label: '분석하기',
                        loading: _isLoading,
                        onPressed: value.text.trim().isNotEmpty ? _analyze : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (sentences.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    '분석 결과가 여기에 나와요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.sub),
                  ),
                )
              else ...[
                SectionTitle('분석 결과', trailing: '문장 ${sentences.length}개'),
                const SizedBox(height: 12),
                for (final sentence in sentences) ...[
                  SentenceRow(
                    sentence: sentence.sentence,
                    translation: sentence.translation,
                    onTap: () => context.pushNamed(RouteNames.sentenceDetail, extra: sentence),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Text(
          '快',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: AppWeights.title, height: 1),
        ),
      ),
    );
  }
}

class _DueCard extends ConsumerWidget {
  const _DueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(dueCountProvider).valueOrNull ?? 0;
    if (due == 0) return const SizedBox.shrink();

    final minutes = (due * 10 / 60).ceil();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        color: AppColors.primarySoft,
        shadow: false,
        outlined: false,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        onTap: () => context.go(RoutePaths.study),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.style_outlined, color: AppColors.primaryText),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('복습할 단어 $due개', style: const TextStyle(fontSize: 16, fontWeight: AppWeights.label)),
                  const SizedBox(height: 2),
                  Text('$minutes분이면 끝나요', style: const TextStyle(fontSize: 13, color: AppColors.sub)),
                ],
              ),
            ),
            const Text(
              '시작 ›',
              style: TextStyle(fontSize: 14, fontWeight: AppWeights.label, color: AppColors.primaryText),
            ),
          ],
        ),
      ),
    );
  }
}
