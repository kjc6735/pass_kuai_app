import 'package:flutter/material.dart';
import 'package:pass_kuai/components/ui.dart';
import 'package:pass_kuai/theme/app_colors.dart';

class SentenceRow extends StatelessWidget {
  final String sentence;
  final String translation;
  final VoidCallback onTap;

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
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sentence,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: AppWeights.hanzi,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  translation,
                  style: const TextStyle(fontSize: 14, color: AppColors.sub),
                ),
              ],
            ),
          ),
          for (final action in actions) ...[const SizedBox(width: 8), action],
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: AppColors.faint),
        ],
      ),
    );
  }
}
