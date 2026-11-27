import 'package:flutter/material.dart';
import 'package:pass_kuai/components/ui.dart';
import 'package:pass_kuai/theme/app_colors.dart';

class WordRow extends StatelessWidget {
  final String text;
  final String pinyin;
  final String meaning;
  final String? pos;

  final List<Color>? charColors;

  final List<Widget> actions;

  const WordRow({
    super.key,
    required this.text,
    required this.pinyin,
    required this.meaning,
    this.pos,
    this.charColors,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final chars = text.characters.toList();
    final colors = charColors;
    final hanziStyle = const TextStyle(
      fontSize: 28,
      fontWeight: AppWeights.hanzi,
      color: AppColors.ink,
    );
    final detail = [
      meaning,
      if (pos != null && pos!.isNotEmpty) pos!,
    ].join(' · ');

    return AppCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 56),
            child: colors == null || colors.length != chars.length
                ? Text(text, style: hanziStyle)
                : Text.rich(
                    TextSpan(
                      children: [
                        for (var i = 0; i < chars.length; i++)
                          TextSpan(
                            text: chars[i],
                            style: hanziStyle.copyWith(color: colors[i]),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pinyin,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: AppWeights.pinyin,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 14, color: AppColors.sub),
                ),
              ],
            ),
          ),
          for (final action in actions) ...[const SizedBox(width: 8), action],
        ],
      ),
    );
  }
}

class SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final IconTileStyle style;

  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip = '',
    this.style = IconTileStyle.soft,
  });

  @override
  Widget build(BuildContext context) {
    return IconTileButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      style: style,
    );
  }
}
