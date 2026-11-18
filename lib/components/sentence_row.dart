import 'package:flutter/material.dart';

/// 분석 화면·단어장에서 공용으로 쓰는 문장 행.
/// 한자(큰 글씨) + 번역(회색) + 오른쪽 chevron.
class SentenceRow extends StatelessWidget {
  final String sentence;
  final String translation;
  final VoidCallback onTap;

  /// 오른쪽 chevron 앞에 붙는 액션 버튼들 (삭제 등).
  final List<Widget> actions;

  const SentenceRow({
    super.key,
    required this.sentence,
    required this.translation,
    required this.onTap,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sentence,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    translation,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
            for (final action in actions) ...[
              const SizedBox(width: 8),
              action,
            ],
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
