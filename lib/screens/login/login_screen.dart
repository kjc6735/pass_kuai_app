import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/router.dart';

/// Google 로그인 화면 (UI).
/// 현재 버튼은 임시로 분석 화면으로 이동한다.
/// 실제 연동은 [_onGoogleSignIn]에 google_sign_in 호출을 연결하면 된다.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _onGoogleSignIn(BuildContext context) async {
    // TODO: 실제 Google 로그인 연동
    //   1) pubspec.yaml 에 google_sign_in 추가
    //   2) 네이티브 설정 (iOS GoogleService-Info.plist / URL scheme,
    //      Android OAuth client ID 또는 Firebase 프로젝트)
    //   3) 아래에서 GoogleSignIn().signIn() 호출 후 토큰 처리
    //   4) 성공 시 context.go(RoutePaths.analyze)
    context.go(RoutePaths.analyze);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ── 브랜드 ─────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '快',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'PASS QUAI',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '로그인하고 중국어 학습을 시작하세요',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(flex: 4),

              // ── Google 로그인 버튼 ─────────────────────
              _GoogleSignInButton(onPressed: () => _onGoogleSignIn(context)),
              const SizedBox(height: 20),

              // ── 약관 안내 ──────────────────────────────
              Text(
                '계속 진행하면 서비스 약관 및\n개인정보 처리방침에 동의하게 됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

/// 앱 톤(블랙)에 맞춘 Google 로그인 버튼.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google "G" 마크 (정식 로고 에셋으로 교체 가능)
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Google로 계속하기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
