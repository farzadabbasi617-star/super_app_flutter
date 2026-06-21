# Super App Flutter

A Flutter super-app prototype with clean architecture, BLoC state management, marketplace, rental, map discovery, profile/wallet and service dispatch flows.

## Current status

- ✅ Flutter project structure is available for `android`, `ios` and `web`.
- ✅ `flutter analyze` passes.
- ✅ Unit/widget tests pass.
- ✅ Web release build is supported.
- ✅ Demo authentication fallback is enabled while the real backend is not connected.
- ⚠️ Google Maps API keys must be configured before using the real map on Android/iOS/Web.

## Quick start

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Build

```bash
flutter build web --release --no-wasm-dry-run
flutter build apk
```

> Android builds should use Java 17+.

## Google Maps setup

Replace `YOUR_GOOGLE_MAPS_API_KEY` in:

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/AppDelegate.swift`
- `web/index.html`

Use restricted keys per platform.

## Useful docs

See [`docs/SETUP.md`](docs/SETUP.md) for setup details.

## Main stack

- Flutter stable
- BLoC / flutter_bloc
- GoRouter
- GetIt
- Dio
- Flutter Secure Storage
- Google Maps Flutter
- Geolocator
- Socket.io client
- dartz / Equatable

## Notes

The root `index.html` file is an interactive HTML simulator for product preview. The Flutter web entry point is `web/index.html`.
