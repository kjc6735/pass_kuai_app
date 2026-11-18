#!/bin/bash

set -e

echo "📦 Building Android..."
flutter clean
flutter pub get
flutter build appbundle --release --dart-define-from-file=config/env.json

echo "✅ Android 빌드 완료!"
echo "파일: build/app/outputs/bundle/release/app-release.aab"