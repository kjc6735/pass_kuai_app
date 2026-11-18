import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/router.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key, this.result});

  final Object? result;

  @override
  Widget build(BuildContext context) {
    final demo = result is String && (result as String).trim().isNotEmpty
        ? [result as String]
        : ['我想喝一杯咖啡', '这家店很有名', '谢谢你的帮助'];

    return Scaffold(
      appBar: AppBar(title: const Text('분석 결과')),
      body: ListView.separated(
        itemCount: demo.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) => ListTile(
          title: Text(demo[i]),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              context.pushNamed(RouteNames.sentenceDetail, extra: demo[i]),
        ),
      ),
    );
  }
}
