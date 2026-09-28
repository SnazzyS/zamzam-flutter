import XCTest

final class ArtworkUITests: XCTestCase {
    func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func open(_ label: String, app: XCUIApplication) {
        let button = app.buttons[label].firstMatch
        if !button.isHittable { app.swipeUp() }
        XCTAssertTrue(button.waitForExistence(timeout: 8))
        button.tap()
        Thread.sleep(forTimeInterval: 0.8)
    }

    func checklist(_ bundle: String, prefix: String) {
        let app = XCUIApplication(bundleIdentifier: bundle)
        app.launch()
        open("ޗެކްލިސްޓް", app: app)
        for page in 1...4 {
            if prefix == "flutter" {
                XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "\(page) / 4")).firstMatch.exists)
            }
            capture("\(prefix)-checklist-\(page)", app: app)
            if page < 4 {
                app.swipeLeft()
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        app.swipeLeft()
        capture("\(prefix)-checklist-boundary", app: app)
        if prefix == "flutter" {
            XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "4 / 4")).firstMatch.exists)
            app.buttons["Back"].tap()
            XCTAssertTrue(app.buttons["ޗެކްލިސްޓް"].firstMatch.waitForExistence(timeout: 5))
        }
    }

    func testFlutterChecklist() {
        checklist("mv.zamzam.flutter", prefix: "flutter")
    }
    func testSwiftChecklist() {
        checklist("mv.zamzam.zamzamMobile", prefix: "swift")
    }

    func office(_ bundle: String, prefix: String) {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication(bundleIdentifier: bundle)
        app.launch()
        open("އޮފީސް", app: app)
        capture("\(prefix)-office-portrait", app: app)
        XCUIDevice.shared.orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1)
        capture("\(prefix)-office-landscape", app: app)
        XCUIDevice.shared.orientation = .portrait
        if prefix == "flutter" {
            app.buttons["Back"].tap()
            XCTAssertTrue(app.buttons["އޮފީސް"].firstMatch.waitForExistence(timeout: 5))
        }
    }
    func testFlutterOffice() { office("mv.zamzam.flutter", prefix: "flutter") }
    func testSwiftOffice() { office("mv.zamzam.zamzamMobile", prefix: "swift") }

    func testFlutterWeatherMotion() {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication(bundleIdentifier: "mv.zamzam.flutter")
        app.launch()
        Thread.sleep(forTimeInterval: 3)
        capture("flutter-motion-clear-clouds-1", app: app)
        Thread.sleep(forTimeInterval: 0.8)
        capture("flutter-motion-clear-clouds-2", app: app)
        app.swipeUp()
        Thread.sleep(forTimeInterval: 1)
        let storm = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "ގުގުރުމާ ވާރޭ")).firstMatch
        XCTAssertTrue(storm.isHittable)
        capture("flutter-motion-rain-storm", app: app)
        app.buttons["ހޯމް"].tap()
        app.buttons["މޫސުން"].tap()
        XCTAssertTrue(storm.isHittable)
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(storm.waitForExistence(timeout: 5))
        XCTAssertTrue(storm.isHittable)
        capture("flutter-motion-resumed", app: app)
    }

    func testWeatherPreview() {
        XCUIDevice.shared.orientation = .portrait
        for (bundle, name) in [("mv.zamzam.reference.weather", "swift-weather"), ("mv.zamzam.flutter", "flutter-weather")] {
            let app = XCUIApplication(bundleIdentifier: bundle)
            app.launch()
            Thread.sleep(forTimeInterval: 2)
            capture(name, app: app)
        }
    }
}
