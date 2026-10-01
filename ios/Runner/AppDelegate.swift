import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// One engine for the phone screen and the car. CarPlay can launch the app with no
  /// phone screen at all, and two engines would mean two radios, so neither scene makes
  /// its own: both use this one, started here.
  lazy var engine: FlutterEngine = {
    let engine = FlutterEngine(name: "seoulfm")
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    CarPlayBridge.shared.attach(messenger: engine.binaryMessenger)
    return engine
  }()

  /// Tells Dart when the listener takes a screenshot, so the player can offer to share.
  private lazy var screenshots = FlutterMethodChannel(name: "fm.seoul/screenshots", binaryMessenger: engine.binaryMessenger)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    _ = engine
    NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main
    ) { [weak self] _ in
      self?.screenshots.invokeMethod("taken", arguments: nil)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
