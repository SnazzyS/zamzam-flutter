# Implementation milestones

Each small coherent increment is verified, committed and pushed to main. Implementation does not imply device or visual acceptance.

| Milestone | Implementation | Verification |
| --- | --- | --- |
| 00 — Reference baseline | Source audit complete | 39 Swift tests and public navigation harness pass; 12 captures; private states/video pending |
| 01 — Flutter foundation | Implemented | Analysis + widget test pass; iOS/Android debug builds and installation/launch pass |
| 02 — Navbar appearance | Pending | Pending |
| 03 — Navbar behavior | Pending | Pending |
| 04 — Shared components | Pending | Pending |
| 05 — Home header and tiles | Pending | Pending |
| 06 — Settings | Pending | Pending |
| 07 — Shared content service | Pending | Pending |
| 08 — Trips card | Pending | Pending |
| 09 — Trips data and states | Pending | Pending |
| 10 — Services card | Pending | Pending |
| 11 — Services paging | Pending | Pending |
| 12 — Services data and states | Pending | Pending |
| 13 — Umrah and Dua | Pending | Pending |
| 14 — Checklist | Pending | Pending |
| 15 — Office | Pending | Pending |
| 16 — One weather card | Pending | Pending |
| 17 — Weather motion | Pending | Pending |
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
