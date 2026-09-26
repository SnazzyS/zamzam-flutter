# Zamzam Flutter

A separate iOS/Android app reproducing Zamzam Swift at `c51eeeb`.

## Run

Use Flutter **3.41.1** / Dart **3.11.0** (see `.fvmrc`), Xcode and Android SDK. Minimum iOS 17 and Android API 26. Development bundle/application ID: `mv.zamzam.flutter`.

```sh
flutter pub get
flutter run
```

## Verify

```sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build ios --simulator --debug
flutter build apk --debug
```

Use JDK 17 for Android. Backend defaults to https://zamzam.mv; later test hosts inject fixtures so automated tests do not send OTPs. Never commit credentials, member data or passport files.

[Milestones](docs/MILESTONES.md) · [Reference](docs/REFERENCE.md) · [Differences](docs/DIFFERENCES.md)

Work proceeds through small verified commits pushed directly to main. This project does not replace or modify the existing native apps.
