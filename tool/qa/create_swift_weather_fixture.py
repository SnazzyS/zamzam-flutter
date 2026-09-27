"""Copy the pinned Swift source to an ignored, deterministic weather fixture."""
from pathlib import Path
import shutil
import subprocess

root = Path(__file__).resolve().parents[2]
source = root.parent / 'zamzam-swift'
expected = 'c51eeeb290d8da1dde477af21dfde0ba078ec289'
assert subprocess.check_output(['git', '-C', str(source), 'rev-parse', 'HEAD'], text=True).strip() == expected
assert not subprocess.check_output(['git', '-C', str(source), 'status', '--porcelain'], text=True).strip()
target = root / 'artifacts' / 'swift-weather-fixture'
for name in ['ZamzamSwift', 'ZamzamSwift.xcodeproj']:
    shutil.copytree(source / name, target / name, dirs_exist_ok=True)
project = target / 'ZamzamSwift.xcodeproj' / 'project.pbxproj'
project.write_text(project.read_text().replace('mv.zamzam.zamzamMobile;', 'mv.zamzam.reference.weather;'))
view = target / 'ZamzamSwift' / 'Views' / 'Schedule' / 'ScheduleView.swift'
view.write_text('''import SwiftUI
struct ScheduleView: View {
    var body: some View {
        ScreenContainer {
            CityWeatherHero(location: .makkah, state: .loaded(
                CityWeather(temperatureCelsius: 37, weatherCode: 0,
                    windSpeedKmh: 18, precipitationMillimeters: 0,
                    precipitationChance: 10, observedAt: nil,
                    fetchedAt: Date(timeIntervalSince1970: 1790467200)),
                isCached: false))
        }
    }
}
''')
# Start on the controlled card while preserving the real navigation geometry.
root_view = target / 'ZamzamSwift' / 'App' / 'RootView.swift'
root_view.write_text(root_view.read_text().replace('selectedTab: RootTab = .home', 'selectedTab: RootTab = .schedule'))
print(target)

canvas = target / 'ZamzamSwift' / 'Views' / 'Schedule' / 'MakkahWeatherHero.swift'
canvas.write_text(canvas.read_text().replace('isAnimated: display.isAnimated && !reduceMotion', 'isAnimated: false'))
