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
