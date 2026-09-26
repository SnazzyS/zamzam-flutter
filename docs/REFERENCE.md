# Swift reference

Reference: `SnazzyS/zamzam-swift`, commit `c51eeeb290d8da1dde477af21dfde0ba078ec289`.
The reference and existing Android repositories remain unchanged.

## Verified baseline

- 39 Swift tests passed on the iPhone 17 Pro / iOS 26.5 simulator on 2026-09-26.
- Public screen capture/navigation harness is running separately from the Swift repository.
- Authentication and passport runtime coverage still requires a designated test account.

## Screen inventory

Root tabs, right to left: Home, Weather, Prayer, Member, Settings. Each has an independent navigation stack. A fresh launch selects Home. Home destinations keep the bottom bar visible.

Home: six original illustrated tiles, Trips, Services, Umrah, Dua, Checklist, Office. Trips renders title, optional price and remote image. Services has an LTR pager with RTL dots, wrapping accessibility actions, and count-change reset. Umrah and Dua are intentionally header-only. Checklist has four bundled illustrated pages, not interactive checkboxes. Office displays location artwork.

Weather: Makkah, Madinah, Taif, Jeddah in this order, each with an independent cache and error state. Four requests run concurrently. Scenes update at 10 fps only while visible and active; reduced motion disables animation.

Prayer: city selection persists; default/fallback is Makkah. Load today and tomorrow concurrently, in calendar order. Six rows include sunrise. Saudi time drives calculations and rollover; device-local time drives hero artwork. Countdown refreshes every 30 seconds.

Member: SMS challenge request, six-digit verification, secure token, /me restoration, profile initials/name, authenticated passport preview and logout. National ID: ^[A-Z][0-9]{6}$; passport: ^[A-Z]{2}[0-9]{7}$. No channel selector.

Settings: fixed Dhivehi/light values and font scales 0.92/1/1.12. No notification setting, guide, booking, payments, or map interaction is introduced.

## Contracts

| Method | Path | Body / special behavior |
| --- | --- | --- |
| GET | /api/website-content | packages/services; shared 30-minute cache |
| POST | /api/v1/auth/customer/login-code | identifier |
| POST | /api/v1/auth/customer/login | challenge_id, code, device_name |
| GET | /api/v1/me | bearer token |
| DELETE | /api/v1/auth/logout | bearer token, best effort remote revocation |
| GET | /api/v1/customer/passport-copy | bearer token, Accept */*, PDF/JPEG |

Default backend: https://zamzam.mv. Ordinary API and weather timeout: 10 seconds. Prayer timeout: 12 seconds. Passport timeout: 30 seconds. No automatic authentication retries.

Open-Meteo /v1/forecast: current=temperature_2m,weather_code,wind_speed_10m,precipitation; daily=precipitation_probability_max; timezone=auto; forecast_days=1. Per-city cache: 45 minutes. Coordinates: Makkah 21.4225/39.8262; Madinah 24.5247/39.5692; Taif 21.4373/40.5127; Jeddah 21.4858/39.1925.

AlAdhan /v1/timings/dd-MM-yyyy: same coordinates, method=4, school=0, timezonestring=Asia/Riyadh. Reject unexpected method, remove parenthesized timing suffixes, cache by city/date.

## Visual values

Background #F4F2EF, primary green #00A443, text #1F2937. MV Waheed and Faruma come from the reference. Screen content max width 460, horizontal padding 24. Navbar height 58 with 6 horizontal internal padding, 54x48 selection, 22/24 icon size, spring response .34/damping .82. Home tiles height 182, corner radius 24, icons 114. Weather card height 224, corner radius 30. Per-screen source values override shared defaults.

## Validation boundaries

Source inspection establishes contracts, not runtime success. Screenshots use the recorded simulator and may contain changing public data; fixture-based comparisons freeze those values. Test credentials, OTPs, tokens and passport documents must not be checked in.
