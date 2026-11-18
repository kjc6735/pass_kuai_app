import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pass_kuai/components/sentence_row.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/provider/analyze_repository_provider.dart';

import '../../router/router.dart';

class AnalyzeHomeScreen extends ConsumerStatefulWidget {
  const AnalyzeHomeScreen({super.key});

  @override
  ConsumerState<AnalyzeHomeScreen> createState() => _AnalyzeHomeScreenState();
}

class _AnalyzeHomeScreenState extends ConsumerState<AnalyzeHomeScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  AnalyzeResult _analyzeResult = AnalyzeResult(sentences: List.empty());

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
      _analyzeResult = await repo.analyzeSentence(sentence: text);

      if (!mounted) return;
      // context.pushNamed(RouteNames.analysisResult, extra: result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('분석에 실패했어요: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('분석', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: () => _showImageSourceSheet(),
            icon: const Icon(Icons.photo_camera_outlined),
            tooltip: '사진으로 분석',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '중국어 문장을 입력하세요!',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: '예) 我想喝一杯咖啡',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) {
                final canAnalyze = value.text.trim().isNotEmpty && !_isLoading;
                return FilledButton(
                  onPressed: canAnalyze ? _analyze : null,

                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '분석하기',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                );
              },
            ),

            const SizedBox(height: 16),
            Expanded(child: _buildResult()),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final sentences = _analyzeResult.sentences;

    if (sentences.isEmpty) {
      return const Center(
        child: Text('분석 결과가 여기에 표시됩니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      itemCount: sentences.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final sentence = sentences[index];
        return SentenceRow(
          sentence: sentence.sentence,
          translation: sentence.translation,
          onTap: () =>
              context.pushNamed(RouteNames.sentenceDetail, extra: sentence),
        );
      },
    );
  }

  Future<void> _showImageSourceSheet() async {
    // final choice = await showCupertinoModalPopup<String>(
    //   context: context,
    //   builder: (context) {
    //     return CupertinoActionSheet(
    //       actions: [
    //         CupertinoActionSheetAction(
    //           onPressed: () => Navigator.pop(context, 'camera'),
    //           child: const Text('📷 사진 찍기'),
    //         ),
    //         CupertinoActionSheetAction(
    //           onPressed: () => Navigator.pop(context, 'gallery'),
    //           child: const Text('🖼️ 갤러리에서 선택'),
    //         ),
    //       ],
    //       cancelButton: CupertinoActionSheetAction(
    //         isDefaultAction: true,
    //         onPressed: () => Navigator.pop(context),
    //         child: const Text('취소'),
    //       ),
    //     );
    //   },
    // );

    // if (choice == 'camera') {
    //   // imagePicker
    // } else if (choice == 'gallery') {
    //   // imagePicker
    // }
  }
}
