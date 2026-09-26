import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ZamzamPlatform")!
    let channel = FlutterMethodChannel(name: "mv.zamzam.flutter/platform", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "symbol", let args = call.arguments as? [String: Any],
        let name = args["name"] as? String else { result(FlutterMethodNotImplemented); return }
      let bold = args["bold"] as? Bool ?? false
      let config = UIImage.SymbolConfiguration(pointSize: 24, weight: bold ? .semibold : .medium)
      guard let symbol = UIImage(systemName: name, withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal),
        let data = symbol.pngData() else { result(nil); return }
      result(["bytes": FlutterStandardTypedData(bytes: data), "width": symbol.size.width, "height": symbol.size.height])
    }
  }
}
