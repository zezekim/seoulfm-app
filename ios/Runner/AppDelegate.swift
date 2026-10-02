import AVKit
import Flutter
import UIKit
import UserNotifications
import WidgetKit

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
    IntentBridge.shared.attach(messenger: engine.binaryMessenger)
    return engine
  }()

  /// What is on air, for the home-screen widget (`HomeWidgets` in Dart), through the App Group.
  private lazy var widgets = FlutterMethodChannel(name: "fm.seoul/widgets", binaryMessenger: engine.binaryMessenger)

  /// The play state Control Center last showed.
  private var controlPlaying: Bool?

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

  /// Reduce Transparency, which Flutter doesn't report: Dart draws its glass solid while it is on
  /// (`AccessibilityPrefs`). Answers "reduceTransparency", and sends the same on every change.
  private lazy var a11y = FlutterMethodChannel(name: "fm.seoul/a11y", binaryMessenger: engine.binaryMessenger)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    _ = engine
    // Request notifications (flutter_local_notifications): taps reach Dart through the app delegate.
    UNUserNotificationCenter.current().delegate = self
    widgets.setMethodCallHandler { [weak self] call, result in
      // The listener's request on its way, for the Live Activity's countdown (null: none).
      if call.method == "request" {
        if #available(iOS 16.2, *) { RadioActivityController.shared.setRequest(call.arguments as? [String: Any]) }
        return result(nil)
      }
      guard call.method == "update", let data = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      let shared = UserDefaults(suiteName: "group.com.seoulfm.seoulfm")
      for (key, value) in data {
        if value is NSNull { shared?.removeObject(forKey: key) } else { shared?.set(value, forKey: key) }
      }
      shared?.set(Date().timeIntervalSince1970, forKey: "savedAt")
      WidgetCenter.shared.reloadAllTimelines()
      if #available(iOS 16.2, *) { RadioActivityController.shared.update(data) }
      // Control Center's play/pause shows the play state; it only needs telling when that changes.
      let playing = data["playing"] as? Bool
      if #available(iOS 18.0, *), let playing, playing != self?.controlPlaying {
        self?.controlPlaying = playing
        ControlCenter.shared.reloadControls(ofKind: "PlaybackControl")
      }
      result(nil)
    }
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
    a11y.setMethodCallHandler { call, result in
      if call.method == "reduceTransparency" {
        result(UIAccessibility.isReduceTransparencyEnabled)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    NotificationCenter.default.addObserver(
      forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil, queue: .main
    ) { [weak self] _ in
      self?.a11y.invokeMethod("reduceTransparency", arguments: UIAccessibility.isReduceTransparencyEnabled)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
