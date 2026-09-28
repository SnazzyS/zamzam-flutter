# Implementation milestones

Each small coherent increment is verified, committed and pushed to main. Implementation does not imply device or visual acceptance.

| Milestone | Implementation | Verification |
| --- | --- | --- |
| 00 — Reference baseline | Source audit complete | 39 Swift tests and public navigation harness pass; 12 captures; private states/video pending |
| 01 — Flutter foundation | Implemented | Analysis + widget test pass; iOS/Android debug builds and installation/launch pass |
| 02 — Navbar appearance | Implemented | Analysis, 2 widget tests, both builds, 5-state iOS UI test and Android capture pass; intrinsic SF Symbol sizing visually corrected |
| 03 — Navbar behavior | Implemented | Analysis and 4 widget tests pass: independent stack retention, reselection, RTL order and Android Back |
| 04 — Shared components | Implemented | Analysis and 6 tests pass, including compact/large-text retry and busy-action suppression; visual checks continue with consumer screens |
| 05 — Home header and tiles | Implemented | Analysis, 7 tests and both debug builds pass; six links return correctly; iOS text bounds within 1 logical pixel of reference after font calibration; Android capture reviewed |
| 06 — Settings | Implemented | Analysis, 12 tests, both debug builds pass; iOS UI test and Android process restart preserve size; captures reviewed; final spacing sweep pending |
| 07 — Shared content service | Implemented | Analysis and 13 focused tests pass: scalar decoding, canonical cache, exact expiry, single request, retained refresh, malformed/offline recovery, error mapping, timeout; live public contract inspected |
| 08 — Trips card | Implemented | Analysis and controlled fixture test pass (mixed-script price, long title, 2× system text); both platform previews built and captured; loaded square artwork matches observed Swift crop |
| 09 — Trips data and states | Implemented | Analysis, 27 regression tests and 2 focused screen-state tests pass; both debug builds pass; live iOS navigation/scroll retention test and Android loading/refresh captures pass; offline/cache paths covered by repository tests |
| 10 — Services card | Implemented | Analysis, compact/large-text fallback/long-copy tests and both preview builds pass; iOS/Android captures reviewed; source image inset, text block alignment, and 4-point inter-line spacing reproduced |
| 11 — Services paging | Implemented | Analysis and 2 widget tests pass: LTR end boundaries, RTL dot selection, accessibility wrap, count reset, reduced motion; both builds and complete-pager captures reviewed |
| 12 — Services data and states | Implemented | Analysis, 32 regression tests and shared-navigation test pass; both builds pass; five live pages, boundary swipe, shared Trips payload and tab retention checked on iOS; all five pages/Back checked on Android |
| 13 — Umrah and Dua | Implemented using shared header layouts | Both header-only screens compared against Swift captures; iOS UI test and Android navigation/Back checks pass; no extra content added |
| 14 — Checklist | Implemented | Analysis, paging/boundary/landscape/tab-retention/reopen tests and both debug builds pass; all four pages captured on iOS/Android, page announcements and Back verified; measured reference artwork offset reproduced; full device sweep pending |
| 15 — Office | Implemented | Analysis, Home/Checklist regression tests and both debug builds pass; iPhone/iPad portrait and landscape captures compared with Swift, Android phone/tablet-sized portrait/landscape captures and Back checks pass |
| 16 — One weather card | Implemented as a controlled preview | Analysis, condition/formatting and compact/large-text tests, both debug builds and fixed-data iOS/Android capture review pass; measured Swift stack geometry and native iOS rounded numerals reproduced; production data wiring belongs to milestone 19 |
| 17 — Weather motion | Implemented | Four focused tests passed before the Xcode license interruption; current analysis and Android build/runtime checks pass; all 12 Swift/Flutter scene keyframes compared; latest iOS runtime/build verification pending Xcode license acceptance |
| 18 — Remaining cities | Pending | Pending |
| 19 — Weather data and recovery | Pending | Pending |
| 20 — Prayer layout | Pending | Pending |
| 21 — City selection and data | Pending | Pending |
| 22 — Prayer calculations | Pending | Pending |
| 23 — Prayer lifecycle and caching | Pending | Pending |
| 24 — Member appearance | Pending | Pending |
| 25 — Identifier behavior | Pending | Pending |
| 26 — Request SMS challenge | Pending | Pending |
| 27 — Verify code | Pending | Pending |
| 28 — Session and profile | Pending | Pending |
| 29 — Passport retrieval | Pending | Pending |
| 30 — Passport viewer | Pending | Pending |
| 31 — Cross-device parity sweep | Pending | Pending |
| 32 — Release candidate | Pending | Pending |

## Per-increment gate

Run formatting check, analysis, relevant unit/widget/integration checks, review affected UI against Swift, update this tracker, review diff, commit and push main. Run both platform builds for foundation, native/dependency changes, feature completion and release. Never replace golden files to conceal an unexplained change.

## Final gate

All screens and meaningful loading/empty/error/cached states; compact/large phones, tablet, landscape, app/system font scales, VoiceOver/TalkBack, keyboard, back gestures, cold launch, resume and Android process recreation. Live public smoke plus separately designated test-account login/passport checks. Profile physical devices; store publication and migration are outside scope.

## Current environment gate — 2026-09-28

Xcode now requires license acceptance. This blocks simulator commands, iOS builds, and the macOS native-asset hook used by fresh Flutter tests. The existing four Weather tests passed before this environment change; static analysis and the Android motion build/runtime checks passed afterward. Resume iOS motion verification after the user reviews/accepts the Xcode license in Terminal. Milestone 17 implementation is pushed, but its iOS runtime verification is not complete. Next implementation milestone: the remaining city scenes, one at a time.
