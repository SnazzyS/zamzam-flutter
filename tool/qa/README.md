# Public artwork captures

These harnesses operate only on public Checklist/Office screens. They never log in, request SMS, or inspect member files. Captures/build outputs go under ignored `artifacts/`.

`create_ios_harness.rb` creates a standalone XCUITest project using CocoaPods' `xcodeproj` Ruby gem. Build/install Flutter and the current Swift source on the chosen simulator, then run the `ArtworkUITests` scheme in `artifacts/ios-harness/Parity.xcodeproj` with parallel testing disabled. Export attachments with `xcrun xcresulttool export attachments`. Do not reuse an arbitrary existing Swift binary: verify the recorded reference commit first.

For an installed Android debug build, run `python3 tool/qa/android_artwork.py --adb /path/to/adb --screen checklist` (or `office`). The harness opens the destination, captures its artwork, and checks Android Back restores Home. Swift/Flutter screenshot comparisons must use matching viewport, app font setting, orientation, and page.

For Weather, `create_swift_weather_fixture.py` verifies the pinned clean Swift checkout, copies it into ignored artifacts, assigns a separate fixture identity, and substitutes fixed public readings and frozen motion. Build/install that copy and Flutter's `tool/previews/weather.dart`, then run `testWeatherPreview`. This never modifies the original Swift repository.

The Swift Weather fixture also exports twelve raw scene frames under its app container's `Documents/weather-frames`. `flutter test tool/qa/weather_frames_test.dart` exports the matching Flutter frames under ignored artifacts. Compare equal style/frame filenames at their original resolution; these helpers generate evidence and never update golden baselines. The iOS SDK must be installed and licensed for the native fixture and macOS Flutter-test native hooks.

For live motion inspection, install `tool/previews/weather_motion.dart` and run `android_weather_motion.py --adb /path/to/adb`. It checks clear/cloud/rain/storm visibility, tab scroll retention, and background/resume using fixed public readings. Timer-pausing assertions live in `test/weather_motion_test.dart`.

On the current Xcode 27 host, CocoaPods must use the app's iOS 17 minimum (enforced by the Podfile). For Flutter 3.41.1's multi-architecture quoting incompatibility, configure the selected preview with `flutter build ios --simulator --debug --config-only -t tool/previews/weather_motion.dart`, then build with `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,id=DEVICE_ID' -derivedDataPath artifacts/ios-preview ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO build`. Install `artifacts/ios-preview/Build/Products/Debug-iphonesimulator/Runner.app`. Run `testFlutterWeatherMotion` for the four-condition preview. This host-specific command does not change the pinned Flutter SDK or the CI build command.
