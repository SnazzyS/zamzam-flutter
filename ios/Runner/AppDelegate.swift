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
      if call.method == "roundedNumber" {
        guard let args = call.arguments as? [String: Any],
          let text = args["text"] as? String, text.count <= 80,
          let points = args["size"] as? Double, points.isFinite, points > 0, points <= 256 else {
          result(nil); return
        }
        let base = UIFont.monospacedDigitSystemFont(ofSize: points, weight: .bold)
        let font = UIFont(descriptor: base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor, size: points)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]
        let textSize = (text as NSString).size(withAttributes: attributes)
        let scale = UIScreen.main.scale
        let size = CGSize(width: max(1, ceil(textSize.width * scale) / scale), height: ceil(font.lineHeight * scale) / scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { _ in
          (text as NSString).draw(at: .zero, withAttributes: attributes)
        }
        guard let data = image.pngData() else { result(nil); return }
        result(["bytes": FlutterStandardTypedData(bytes: data), "width": size.width, "height": size.height])
        return
      }
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
