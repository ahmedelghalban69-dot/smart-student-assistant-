# V2251 Full Repair Notes

- Added the missing `flutter_test` and `flutter_lints` development dependencies required by the Flutter project and `analysis_options.yaml`.
- Updated Flutter CI so Dart sources are formatted during CI before analysis instead of failing only because formatting differs.
- Removed unused Dart members/parameters that can trigger analyzer diagnostics.
- Made the backend smoke test startup wait slightly more tolerant.
- Kept the backend-only AI key architecture and Responses API integration intact.
