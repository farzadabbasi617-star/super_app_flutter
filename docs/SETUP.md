# Super App Setup Guide

## Requirements

- Flutter stable
- Dart SDK bundled with Flutter
- Java 17 for Android builds
- Xcode for iOS builds on macOS

## First run

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Google Maps API keys

The project contains placeholders that must be replaced before using the real map on device/web:

- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/AppDelegate.swift`
- Web: `web/index.html`

Search for:

```text
YOUR_GOOGLE_MAPS_API_KEY
```

Use platform-restricted keys in production.

## Demo authentication

Until a real backend is connected, the auth remote datasource falls back to demo users if the API is unreachable. This keeps the app navigable during development.

## Useful commands

```bash
flutter analyze --no-pub
flutter test
flutter build web --release --no-wasm-dry-run
flutter build apk
```
