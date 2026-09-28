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

# Export the unmodified drawing commands at identical deterministic frame times.
# The fixture-only time input never changes the original Swift source.
content = canvas.read_text().replace('    let isAnimated: Bool\n', '    let isAnimated: Bool\n    var referenceTime: TimeInterval = 0\n').replace('canvas(time: 0)', 'canvas(time: referenceTime)')
content += '''
@MainActor
func exportWeatherReferenceFrames() {
    let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("weather-frames", isDirectory: true)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let styles: [WeatherAnimationStyle] = [.clear, .cloudy, .rain, .staticFallback]
    for style in styles {
        for frame in 0..<3 {
            let view = AnimatedWeatherCanvas(location: .makkah, style: style,
                isAnimated: false, referenceTime: Double(frame) * 0.8)
                .frame(width: 354, height: 231)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 3
            if let data = renderer.uiImage?.pngData() {
                try? data.write(to: directory.appendingPathComponent("\\(style.rawValue)-\\(frame).png"))
            }
        }
    }
}
'''
canvas.write_text(content)
view.write_text(view.read_text().replace('''        }
    }
}''', '''        }
        .onAppear { exportWeatherReferenceFrames() }
    }
}'''))
