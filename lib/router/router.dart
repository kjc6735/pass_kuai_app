import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/root_shell.dart';
import '../screens/analyze/analyze_home_screen.dart';
import '../screens/analyze/analysis_result_screen.dart';
import '../screens/analyze/sentence_detail_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/vocab/vocab_screen.dart';

abstract final class RoutePaths {
  // 진입(스플래시)
  static const splash = '/splash';
  static const login = '/login';

  // 탭(브랜치) 루트
  static const analyze = '/analyze';
  static const vocab = '/vocab';

  // 루트 네비게이터에 push (전체화면, 하단 탭 가림)
  static const analysisResult = '/result';
  static const sentenceDetail = '/detail';
}

abstract final class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const analyze = 'analyze';
  static const vocab = 'vocab';
  static const analysisResult = 'analysisResult';
  static const sentenceDetail = 'sentenceDetail';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final _analyzeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'analyze');
final _vocabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'vocab');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  routes: [
    // 스플래시 (전체화면, 초기화 후 로그인 화면으로 이동)
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),

    // 로그인 (전체화면)
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),

    // ── 하단 탭 셸 ─────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootShell(navigationShell: navigationShell),
      branches: [
        // 탭 0 · 분석
        StatefulShellBranch(
          navigatorKey: _analyzeNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.analyze,
              name: RouteNames.analyze,
              builder: (context, state) => const AnalyzeHomeScreen(),
            ),
          ],
        ),
        // 탭 1 · 단어장
        StatefulShellBranch(
          navigatorKey: _vocabNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.vocab,
              name: RouteNames.vocab,
              builder: (context, state) => const VocabScreen(),
            ),
          ],
        ),
      ],
    ),

    // 분석 결과 (문장 리스트) — 루트 네비게이터, 어느 탭에서든 전체화면 push
    GoRoute(
      path: RoutePaths.analysisResult,
      name: RouteNames.analysisResult,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => AnalysisResultScreen(result: state.extra),
    ),

    GoRoute(
      path: RoutePaths.sentenceDetail,
      name: RouteNames.sentenceDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => SentenceDetailScreen(sentence: state.extra),
    ),
  ],
);
