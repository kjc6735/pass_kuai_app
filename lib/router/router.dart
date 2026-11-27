import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pass_kuai/layout/root_shell.dart';
import 'package:pass_kuai/screens/analyze/analyze_home_screen.dart';
import 'package:pass_kuai/screens/analyze/sentence_detail_screen.dart';
import 'package:pass_kuai/screens/practice/pronunciation_screen.dart';
import 'package:pass_kuai/screens/splash/splash_screen.dart';
import 'package:pass_kuai/screens/study/study_screen.dart';
import 'package:pass_kuai/screens/vocab/vocab_screen.dart';

abstract final class RoutePaths {
  static const splash = '/splash';

  static const analyze = '/analyze';
  static const study = '/study';
  static const vocab = '/vocab';

  static const sentenceDetail = '/detail';
  static const practice = '/practice';
}

abstract final class RouteNames {
  static const splash = 'splash';
  static const analyze = 'analyze';
  static const study = 'study';
  static const vocab = 'vocab';
  static const sentenceDetail = 'sentenceDetail';
  static const practice = 'practice';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final _analyzeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'analyze');
final _studyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'study');
final _vocabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'vocab');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootShell(navigationShell: navigationShell),
      branches: [
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
        StatefulShellBranch(
          navigatorKey: _studyNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.study,
              name: RouteNames.study,
              builder: (context, state) => const StudyScreen(),
            ),
          ],
        ),
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

    GoRoute(
      path: RoutePaths.sentenceDetail,
      name: RouteNames.sentenceDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => SentenceDetailScreen(sentence: state.extra),
    ),

    GoRoute(
      path: RoutePaths.practice,
      name: RouteNames.practice,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PronunciationScreen(target: state.extra),
    ),
  ],
);
