import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/router/router.dart';
import 'package:pass_kuai/theme/app_colors.dart';

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
    _scale = Tween<double>(
      begin: 0.86,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final warmUp = _warmUpDatabase();
    final minVisible = Future<void>.delayed(const Duration(milliseconds: 1600));
    await Future.wait([warmUp, minVisible]);

    if (!mounted) return;
    context.go(RoutePaths.analyze);
  }

  Future<void> _warmUpDatabase() async {
    try {
      final db = ref.read(dbProvider);
      await db.customSelect('SELECT 1').get();
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
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
                        fontWeight: AppWeights.title,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'PASS KUAI',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 28,
                    fontWeight: AppWeights.title,
                    letterSpacing: 5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '중국어 문장 분석',
                  style: TextStyle(
                    color: AppColors.sub,
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
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
