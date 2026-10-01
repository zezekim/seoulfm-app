import CarPlay
import Flutter
import UIKit

// MARK: - Phone

/// The phone's window, showing the shared engine (see `AppDelegate.engine`).
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene,
      let app = UIApplication.shared.delegate as? AppDelegate
    else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = FlutterViewController(engine: app.engine, nibName: nil, bundle: nil)
    window.makeKeyAndVisible()
    self.window = window
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Releases the view controller, so a new window can attach to the engine.
    window = nil
  }
}

// MARK: - Bridge to Dart

/// `lib/platform/carplay_bridge.dart`: Dart sends the station list (with what each plays),
/// the car sends back the station the driver picked.
final class CarPlayBridge {
  static let shared = CarPlayBridge()

  private var channel: FlutterMethodChannel?
  private(set) var stations: [[String: Any]] = []
  var onChange: (() -> Void)?

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "fm.seoul/carplay", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "setStations":
        self?.stations = (call.arguments as? [[String: Any]]) ?? []
        self?.onChange?()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  func tune(_ key: String) {
    channel?.invokeMethod("tune", arguments: key)
  }
}

// MARK: - CarPlay

/// The car: a list of stations, each with the cover of what it plays now, and the system
/// Now Playing screen, which reads the lock-screen metadata the audio service publishes.
/// Needs the `com.apple.developer.carplay-audio` entitlement.
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
  private var interfaceController: CPInterfaceController?
  private var listTemplate: CPListTemplate?
  private var images: [String: UIImage] = [:]
  private var loading: Set<String> = []
  private var refreshPending = false

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didConnect interfaceController: CPInterfaceController
  ) {
    self.interfaceController = interfaceController
    // Starts the radio if the car launched the app.
    if let app = UIApplication.shared.delegate as? AppDelegate { _ = app.engine }

    let list = CPListTemplate(title: "SeoulFM", sections: [section()])
    list.tabTitle = "Stations"
    list.tabImage = UIImage(systemName: "dot.radiowaves.left.and.right")
    listTemplate = list
    interfaceController.setRootTemplate(list, animated: false, completion: nil)

    CarPlayBridge.shared.onChange = { [weak self] in self?.scheduleRefresh() }
  }

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didDisconnect interfaceController: CPInterfaceController
  ) {
    CarPlayBridge.shared.onChange = nil
    self.interfaceController = nil
    listTemplate = nil
  }

  private func section() -> CPListSection {
    let items: [CPListItem] = CarPlayBridge.shared.stations.map { station in
      let key = station["key"] as? String ?? ""
      let art = station["art"] as? String
      let color = UIColor(argb: station["color"] as? Int ?? 0xFFF4F4F5)
      let image = art.flatMap { images[$0] } ?? placeholder(color)
      let item = CPListItem(text: station["name"] as? String, detailText: station["detail"] as? String, image: image)
      item.isPlaying = station["playing"] as? Bool ?? false
      item.playingIndicatorLocation = .trailing
      item.handler = { [weak self] _, completion in
        CarPlayBridge.shared.tune(key)
        self?.showNowPlaying()
        completion()
      }
      if let art { load(art) }
      return item
    }
    return CPListSection(items: items)
  }

  /// Coalesces updates: covers arrive one by one.
  private func scheduleRefresh() {
    guard !refreshPending else { return }
    refreshPending = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      guard let self else { return }
      self.refreshPending = false
      self.listTemplate?.updateSections([self.section()])
    }
  }

  private func showNowPlaying() {
    guard let ic = interfaceController else { return }
    let nowPlaying = CPNowPlayingTemplate.shared
    if ic.topTemplate !== nowPlaying {
      ic.pushTemplate(nowPlaying, animated: true, completion: nil)
    }
  }

  private func load(_ url: String) {
    guard images[url] == nil, !loading.contains(url), let u = URL(string: url) else { return }
    loading.insert(url)
    URLSession.shared.dataTask(with: u) { [weak self] data, _, _ in
      let image = data.flatMap { UIImage(data: $0) }
      DispatchQueue.main.async {
        guard let self else { return }
        self.loading.remove(url)
        guard let image else { return }
        if self.images.count > 64 { self.images.removeAll() }
        self.images[url] = image
        self.scheduleRefresh()
      }
    }.resume()
  }

  private func placeholder(_ color: UIColor) -> UIImage {
    let size = CPListItem.maximumImageSize
    return UIGraphicsImageRenderer(size: size).image { ctx in
      color.withAlphaComponent(0.35).setFill()
      ctx.fill(CGRect(origin: .zero, size: size))
      let icon = UIImage(systemName: "dot.radiowaves.left.and.right")?
        .withTintColor(.white, renderingMode: .alwaysOriginal)
      let side = size.width * 0.5
      icon?.draw(in: CGRect(x: (size.width - side) / 2, y: (size.height - side) / 2, width: side, height: side))
    }
  }
}

private extension UIColor {
  convenience init(argb: Int) {
    self.init(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255)
  }
}
