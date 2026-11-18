#!/bin/bash

set -e

echo "🍎 Building iOS..."
flutter clean
flutter pub get
flutter build ipa --release --dart-define-from-file=config/env.json

echo "✅ iOS 빌드 완료!"
echo "파일: build/ios/ipa/*.ipa"