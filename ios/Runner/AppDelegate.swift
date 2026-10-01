import AVKit
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

  /// Opens the system AirPlay picker for the player's output button (`OutputDeviceButton`).
  private lazy var output = FlutterMethodChannel(name: "fm.seoul/output", binaryMessenger: engine.binaryMessenger)
  private lazy var routePicker = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

  /// Taps a hidden `AVRoutePickerView`'s button: the documented way to show the picker is the
  /// view itself, and drawing a native view inside the Flutter player breaks its masks.
  private func showAirPlayPicker() {
    guard let window = UIApplication.shared.connectedScenes
      .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first
    else { return }
    if routePicker.superview == nil {
      routePicker.alpha = 0.011
      routePicker.isUserInteractionEnabled = false
      window.addSubview(routePicker)
    }
    for case let button as UIButton in routePicker.subviews {
      button.sendActions(for: .touchUpInside)
      return
    }
  }

  /// Tells Dart when the listener takes a screenshot, so the player can offer to share.
  private lazy var screenshots = FlutterMethodChannel(name: "fm.seoul/screenshots", binaryMessenger: engine.binaryMessenger)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    _ = engine
    output.setMethodCallHandler { [weak self] call, result in
      if call.method == "pick" {
        self?.showAirPlayPicker()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main
    ) { [weak self] _ in
      self?.screenshots.invokeMethod("taken", arguments: nil)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
