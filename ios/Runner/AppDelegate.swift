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

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    _ = engine
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
