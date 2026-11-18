#!/bin/bash

set -e

ENV_FILE="config/env.json"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ $ENV_FILE 파일이 없습니다!"
    exit 1
fi

echo "🤖 Android Release Run"
echo ""

# Android 기기 확인 (두 번째 • 다음의 값)
ANDROID_DEVICE=$(flutter devices | grep "android" | head -n 1 | awk -F'•' '{print $2}' | xargs)

if [ -z "$ANDROID_DEVICE" ]; then
    echo "❌ 연결된 Android 기기가 없습니다."
    exit 1
fi

echo "✅ 디바이스: $ANDROID_DEVICE"
echo ""

flutter run --release --dart-define-from-file=$ENV_FILE -d "$ANDROID_DEVICE"