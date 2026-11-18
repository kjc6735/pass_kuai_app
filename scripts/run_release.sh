#!/bin/bash

set -e

ENV_FILE="config/env.json"

# 환경변수 파일 확인
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ $ENV_FILE 파일이 없습니다!"
    exit 1
fi

echo "🚀 Flutter Release Run"
echo "====================="
echo ""

# 연결된 디바이스 확인
echo "📱 연결된 디바이스 확인 중..."
DEVICES=$(flutter devices | grep -E "android|ios" | grep -v "emulator")

if [ -z "$DEVICES" ]; then
    echo "❌ 연결된 Android/iOS 기기가 없습니다."
    echo ""
    echo "다음을 확인해주세요:"
    echo "  - Android: USB 디버깅 활성화 및 기기 연결"
    echo "  - iOS: 기기 연결 및 Xcode에서 신뢰 설정"
    exit 1
fi

echo "✅ 연결된 디바이스:"
echo "$DEVICES"
echo ""

# 디바이스 ID 추출 (두 번째 • 다음의 값)
DEVICE_ID=$(echo "$DEVICES" | head -n 1 | awk -F'•' '{print $2}' | xargs)

echo "🎯 선택된 디바이스: $DEVICE_ID"
echo ""
echo "▶️  앱 실행 중..."
echo ""

# 릴리즈 모드로 실행
flutter run --release --dart-define-from-file=$ENV_FILE -d "$DEVICE_ID"