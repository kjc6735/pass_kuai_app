#!/bin/bash

set -e  # 에러 발생 시 중단

echo "🚀 Flutter Release Build Script"
echo "================================"

# 환경변수 파일 확인
ENV_FILE="config/env.json"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ $ENV_FILE 파일이 없습니다!"
    exit 1
fi

echo "✅ 환경변수 파일 확인: $ENV_FILE"

# 클린 빌드
echo ""
echo "🧹 Cleaning..."
flutter clean
flutter pub get

# Android 빌드
echo ""
echo "📦 Building Android App Bundle..."
flutter build appbundle --release --dart-define-from-file=$ENV_FILE

if [ $? -eq 0 ]; then
    echo "✅ Android 빌드 성공!"
    echo "   파일 위치: build/app/outputs/bundle/release/app-release.aab"
else
    echo "❌ Android 빌드 실패"
    exit 1
fi

# iOS 빌드
echo ""
echo "🍎 Building iOS IPA..."
flutter build ipa --release --dart-define-from-file=$ENV_FILE

if [ $? -eq 0 ]; then
    echo "✅ iOS 빌드 성공!"
    echo "   파일 위치: build/ios/ipa/*.ipa"
else
    echo "❌ iOS 빌드 실패"
    exit 1
fi

# 최종 결과
echo ""
echo "================================"
echo "🎉 모든 빌드 완료!"
echo ""
echo "📱 배포 파일:"
echo "  Android: build/app/outputs/bundle/release/app-release.aab"
echo "  iOS:     build/ios/ipa/*.ipa"
echo ""
echo "다음 단계:"
echo "  1. Android: Google Play Console에 AAB 업로드"
echo "  2. iOS: App Store Connect에 IPA 업로드 (Transporter 앱 사용)"