# Differences and reliability decisions

## Approved differences

- Separate identity mv.zamzam.flutter; no existing-user migration.
- Preserve Swift app layout on Android while using platform system UI and Back behavior.
- Native SF Symbols on iOS where needed; licensed Cupertino equivalents on Android. Exact glyph differences require visual review.
- Fix request races, challenge expiry, token-save failures and temporary passport cleanup without adding product sections.
- Unsupported/invalid passport bytes are rejected instead of treating all non-PDF data as JPEG.

## Transport

SSH access was unavailable at setup. The same existing GitHub repository is reached through authenticated HTTPS. No repository or branch is created on GitHub.

## Pending verification

Native material blur, font rasterization, native viewer details, accessibility and physical-device performance must be assessed; none are accepted solely from source inspection.

## Navbar review

iOS preserves SF Symbols intrinsic width/height for matching font sizes. Android Cupertino symbols differ in some glyphs (notably Member); layout and active states are shared. Glass uses a clipped Flutter blur rather than an Apple material, requiring final review over completed screens.

## Dhivehi typography calibration

MV Waheed is a single regular face. Flutter synthetic bold and inherited Cupertino SF tracking initially differed from Swift. Use regular weight, explicit zero tracking and the font ascent/descent line factor 1.465. iPhone 17 Pro capture: reference title bounds (936,320)-(1132,405), Flutter (938,319)-(1133,403); Trips label reference (812,971)-(962,1023), Flutter (813,969)-(961,1020), physical pixels at 3x. Remaining antialiasing differences are renderer-specific. Home tiles grow vertically with large system text to preserve readability.

## Settings review

The segmented control uses a Flutter capsule to match the current Swift system picker silhouette. iOS and Android selection survives process restart. System font fallback differs between platforms. The iOS Settings section/card vertical positions remain approximately 2–3 logical pixels above the reference and are tracked for the final typography/spacing sweep.

## Trips image sizing

Source requests a 1.35 placeholder aspect ratio, but the Swift runtime renders loaded square package images at their natural square ratio. Flutter preserves this observed behavior, including the 1.35 loading/error placeholder. Controlled preview: `flutter run -t tool/previews/trips.dart`. Public artwork fixture was fetched from the existing package URL on 2026-09-27.

## Services card review

The Swift image box fits its 1.24 aspect within the fixed outer frame, leaving surface-colored side insets. Flutter reproduces those insets rather than filling the entire outer frame. Multiline descriptions retain the first baseline and add 4 logical pixels only between lines. Cards may grow for compact/large-text content that would otherwise clip; normal reference-size content retains its original height. The standalone preview has unclipped shadows; the following pager milestone restores the reference page clipping. Small renderer-dependent text-width differences remain for the final sweep.

## Checklist artwork placement

The iPhone reference renders a 774-point-tall image shifted down 31 points inside the 774-point content region. Comparing the original image at candidate scales/offsets confirmed this is a placement effect, not an asset border. Flutter preserves the full-height crop and shifts by half the top safe-area inset, with white behind it. All four original illustrations remain in the Swift order, including the original asset-name/content mismatch. Portrait phone comparison is recorded; the complete tablet/landscape reference sweep remains milestone 31. Page indicators are passive, announce the current page, and obey reduced motion.

## Weather card calibration

Controlled preview: `flutter run -t tool/previews/weather.dart`. The copied Swift fixture uses the same 37-degree/18-km-h/10-percent readings and freezes its original canvas at time zero; `tool/qa/create_swift_weather_fixture.py` creates it only under ignored artifacts after verifying the clean reference commit. The original Swift repository is unchanged.

The Swift runtime's 224-point card clips a 231-point content stack, with a 28-2/3-point constrained title line box. Flutter reproduces those measured dimensions. At enlarged system text it permits additional height and fits temperature on one line to avoid overflow. The iOS adapter uses public UIFont rounded/monospaced-digit APIs to preserve numeral shapes, Arabic fallback and line metrics, with a bounded 128-entry cache. Apple fonts are not bundled on either platform. Android uses installed system typefaces; remaining numeric glyph differences are a platform exception. Final renderer/typography convergence remains milestone 31.

## Weather motion comparison

The original Swift drawing commands and Flutter painter were rendered at 354×231 logical points, 3× scale, at 0, 0.8 and 1.6 seconds for clear, cloudy, rain and fallback scenes. All 12 comparisons were reviewed; maximum mean absolute error among RGB channels was 0.406 on a 0–255 scale. These are isolated scene comparisons, not full-screen or platform golden acceptance. Measurements are recorded in `reference/weather-motion-comparison.json`; reproducible capture helpers are under `tool/qa/`.

A 100-ms timer repaints each visible scene. Unit/widget checks cover its exact cadence, hidden-tab/reduced-motion/background pausing, offscreen scroll pausing, and resumed motion. Android's controlled preview confirms all conditions, changing frames, retained scroll position across tab switches, and background/resume. The iOS motion preview also passes clear/cloud/rain/storm rendering, tab scroll retention and background/resume checks on iPhone 17 Pro / iOS 26.5. Timer pausing itself is asserted in the focused widget tests.
