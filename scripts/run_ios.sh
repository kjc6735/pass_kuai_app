#!/bin/bash

set -e

ENV_FILE="config/env.json"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ $ENV_FILE 파일이 없습니다!"
    exit 1
fi

echo "🍎 iOS Release Run"
echo ""

# iOS 기기 확인 (시뮬레이터 제외, 두 번째 • 다음의 값)
IOS_DEVICE=$(flutter devices | grep "ios" | grep -v "Simulator" | head -n 1 | awk -F'•' '{print $2}' | xargs)

if [ -z "$IOS_DEVICE" ]; then
    echo "❌ 연결된 iOS 기기가 없습니다."
    echo "💡 시뮬레이터를 사용하려면 다음 명령어를 사용하세요:"
    echo "   flutter run --release --dart-define-from-file=$ENV_FILE"
    exit 1
fi

echo "✅ 디바이스: $IOS_DEVICE"
echo ""

flutter run --release --dart-define-from-file=$ENV_FILE -d "$IOS_DEVICE"
