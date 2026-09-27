# Public artwork captures

These harnesses operate only on public Checklist/Office screens. They never log in, request SMS, or inspect member files. Captures/build outputs go under ignored `artifacts/`.

`create_ios_harness.rb` creates a standalone XCUITest project using CocoaPods' `xcodeproj` Ruby gem. Build/install Flutter and the current Swift source on the chosen simulator, then run the `ArtworkUITests` scheme in `artifacts/ios-harness/Parity.xcodeproj` with parallel testing disabled. Export attachments with `xcrun xcresulttool export attachments`. Do not reuse an arbitrary existing Swift binary: verify the recorded reference commit first.

For an installed Android debug build, run `python3 tool/qa/android_artwork.py --adb /path/to/adb --screen checklist` (or `office`). The harness opens the destination, captures its artwork, and checks Android Back restores Home. Swift/Flutter screenshot comparisons must use matching viewport, app font setting, orientation, and page.

For Weather, `create_swift_weather_fixture.py` verifies the pinned clean Swift checkout, copies it into ignored artifacts, assigns a separate fixture identity, and substitutes fixed public readings and frozen motion. Build/install that copy and Flutter's `tool/previews/weather.dart`, then run `testWeatherPreview`. This never modifies the original Swift repository.
