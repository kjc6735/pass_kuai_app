import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../provider/db_provider.dart';
import '../../router/router.dart';

/// 앱 진입 시 가장 먼저 보이는 스플래시 화면.
/// 등장 애니메이션을 보여주는 동안 초기화(DB 워밍업)를 끝내고
/// 완료되면 분석 탭으로 이동한다.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _bootstrap();
  }

  /// 최소 노출 시간과 실제 초기화를 병렬로 진행한 뒤 다음 화면으로 이동.
  Future<void> _bootstrap() async {
    final warmUp = _warmUpDatabase();
    final minVisible = Future<void>.delayed(const Duration(milliseconds: 1600));
    await Future.wait([warmUp, minVisible]);

    if (!mounted) return;
    context.go(RoutePaths.login);
  }

  /// DB를 미리 열어 첫 화면 진입 시 끊김을 줄인다.
  /// 실패해도 앱 진입은 막지 않는다.
  Future<void> _warmUpDatabase() async {
    try {
      final db = ref.read(dbProvider);
      await db.customSelect('SELECT 1').get();
    } catch (_) {
      // 워밍업 실패는 무시
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로고 타일
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '快',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // 워드마크
                const Text(
                  'PASS QUAI',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '중국어 문장 분석',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 48),
        child: SizedBox(
          height: 22,
          width: 22,
          child: Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}