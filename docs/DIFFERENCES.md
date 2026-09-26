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
