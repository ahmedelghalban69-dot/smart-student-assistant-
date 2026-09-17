# Android APK Build — V2251 repaired

This project now contains a committed Android/Gradle project instead of creating Android files during CI.

Key CI changes:
- actions/setup-java@v5
- gradle/actions/setup-gradle@v4 with Gradle 8.10.2
- Removed `flutter create --platforms=android .` from CI
- APK is built with `gradle -p android assembleRelease`
- APK artifact: `build/app/outputs/flutter-apk/app-release.apk`

The Dart source files were not intentionally changed by this Android/CI repair.
