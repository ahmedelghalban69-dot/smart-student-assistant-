#!/usr/bin/env bash
set -euo pipefail
command -v flutter >/dev/null || { echo 'Flutter SDK is required.'; exit 1; }
flutter pub get
flutter create --platforms=android,ios,web .
flutter analyze
flutter test
flutter build web --release
