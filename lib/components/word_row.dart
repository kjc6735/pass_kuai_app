import 'package:flutter/material.dart';

/// 단어 한 줄 — 문장분석·단어장에서 공용.
/// 한자(큰 글씨) + 병음 + 뜻 + 품사 + 오른쪽 액션 버튼들.
class WordRow extends StatelessWidget {
  final String text;
  final String pinyin;
  final String meaning;
  final String? pos;

  /// 오른쪽에 붙는 사각 버튼들 (재생/추가/삭제 등). 화면마다 다르게 넘긴다.
  final List<Widget> actions;

  const WordRow({
    super.key,
    required this.text,
    required this.pinyin,
    required this.meaning,
    this.pos,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          // 한자
          Text(
            text,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pinyin,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(meaning, style: const TextStyle(fontSize: 16)),
                if (pos != null && pos!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    pos!,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// 단어 행 오른쪽의 사각 아이콘 버튼.
class SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 26, color: Colors.black54),
      ),
    );
  }
}
