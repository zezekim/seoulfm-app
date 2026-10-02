import AppIntents
import Flutter
import Foundation

// MARK: - Siri and Shortcuts

/// The stations, by their keys in `lib/data/channels.dart`. An enum rather than an entity:
/// the line-up is fixed, and Siri can match a spoken name without asking the app.
@available(iOS 16.0, *)
enum RadioStation: String, AppEnum {
  case seoulfm, hifi, new, marathon, dance
  case s2010s = "2010s"
  case classics, indie, hiphop, rnb, ballad, ost

  static var typeDisplayRepresentation: TypeDisplayRepresentation = "Station"
  static var caseDisplayRepresentations: [RadioStation: DisplayRepresentation] = [
    .seoulfm: "Pop!",
    .hifi: "HIFI",
    .new: "Fresh K-Pop!",
    .marathon: "Marathon",
    .dance: "Dance",
    .s2010s: "2010s",
    .classics: "Classics",
    .indie: "Indie",
    .hiphop: "HipHop",
    .rnb: "R&B",
    .ballad: "Ballad",
    .ost: "OST",
  ]
}

/// From iOS 17 the intents are `AudioPlaybackIntent`s, which may start audio in the background.
/// Before that the app has to come forward first: Siri asks to open it (16.4 and later; on
/// earlier versions the radio tries from the background). `openAppWhenRun` can't say this:
/// it must be a constant.
@available(iOS 16.0, *)
private func comeForwardBeforeIOS17<I: AppIntent>(_ intent: I) async throws {
  if #available(iOS 17.0, *) { return }
  if #available(iOS 16.4, *), let intent = intent as? any ForegroundContinuableIntent {
    try await intent.requestToContinueInForeground()
  }
}

@available(iOS 16.0, *)
struct PlayStationIntent: AppIntent {
  static var title: LocalizedStringResource = "Play Station"
  static var description = IntentDescription("Plays a SeoulFM station.")

  @Parameter(title: "Station")
  var station: RadioStation

  init() {}

  init(station: RadioStation) {
    self.station = station
  }

  static var parameterSummary: some ParameterSummary {
    Summary("Play \(\.$station)")
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    try await comeForwardBeforeIOS17(self)
    await RadioCommands.run(.play(station: station.rawValue))
    return .result()
  }
}

/// "Play SeoulFM": the station the listener last had on.
@available(iOS 16.0, *)
struct ResumeRadioIntent: AppIntent {
  static var title: LocalizedStringResource = "Play SeoulFM"
  static var description = IntentDescription("Plays the station you last listened to.")

  @MainActor
  func perform() async throws -> some IntentResult {
    try await comeForwardBeforeIOS17(self)
    await RadioCommands.run(.resume)
    return .result()
  }
}

@available(iOS 16.0, *)
struct PauseRadioIntent: AppIntent {
  static var title: LocalizedStringResource = "Pause SeoulFM"
  static var description = IntentDescription("Pauses the radio.")

  @MainActor
  func perform() async throws -> some IntentResult {
    await RadioCommands.run(.pause)
    return .result()
  }
}

// From iOS 17 these run in the background and may start audio there.
@available(iOS 17.0, *)
extension PlayStationIntent: AudioPlaybackIntent {}
@available(iOS 17.0, *)
extension ResumeRadioIntent: AudioPlaybackIntent {}
@available(iOS 17.0, *)
extension PauseRadioIntent: AudioPlaybackIntent {}
// iOS 16: playing asks to open the app (see `comeForwardBeforeIOS17`).
@available(iOS 16.4, *)
extension PlayStationIntent: ForegroundContinuableIntent {}
@available(iOS 16.4, *)
extension ResumeRadioIntent: ForegroundContinuableIntent {}

/// The phrases Siri knows without setup. Translations: AppShortcuts.xcstrings.
@available(iOS 16.0, *)
struct SeoulFMShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: PlayStationIntent(),
      phrases: [
        "Play \(\.$station) on \(.applicationName)",
        "Listen to \(\.$station) on \(.applicationName)",
        "Put on \(\.$station) on \(.applicationName)",
      ])
    AppShortcut(
      intent: ResumeRadioIntent(),
      phrases: [
        "Play \(.applicationName)",
        "Resume \(.applicationName)",
        "Listen to \(.applicationName)",
      ])
    AppShortcut(
      intent: PauseRadioIntent(),
      phrases: [
        "Pause \(.applicationName)",
        "Stop \(.applicationName)",
      ])
  }
}

// MARK: - Bridge to Dart

/// `lib/platform/intents_bridge.dart`. An intent can launch the app in the background, before
/// Dart is running: commands wait here until Dart says it is ready, and each intent waits
/// for its command to be done, so the system keeps the app awake while the stream starts.
final class IntentBridge {
  static let shared = IntentBridge()

  private var channel: FlutterMethodChannel?
  private var ready = false
  private var pending: [(method: String, arguments: Any?, done: (Bool) -> Void)] = []

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "fm.seoul/intents", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "ready" else { return result(FlutterMethodNotImplemented) }
      self?.ready = true
      self?.flush()
      result(nil)
    }
    self.channel = channel
    RadioCommands.handler = { [weak self] command in
      guard let self else { return }
      switch command {
      case .play(let station): _ = await self.send("play", station)
      case .resume: _ = await self.send("resume")
      case .pause: _ = await self.send("pause")
      }
    }
  }

  @MainActor
  func send(_ method: String, _ arguments: Any? = nil) async -> Bool {
    await withCheckedContinuation { continuation in
      var finished = false
      let done: (Bool) -> Void = { ok in
        guard !finished else { return }
        finished = true
        continuation.resume(returning: ok)
      }
      pending.append((method, arguments, done))
      if ready { flush() }
      // Dart never answered (it failed to start): let Siri go. The command stays queued.
      DispatchQueue.main.asyncAfter(deadline: .now() + 15) { done(false) }
    }
  }

  private func flush() {
    guard let channel else { return }
    let items = pending
    pending = []
    for item in items {
      channel.invokeMethod(item.method, arguments: item.arguments) { result in
        item.done(!(result is FlutterError) && (result as AnyObject?) !== FlutterMethodNotImplemented)
      }
    }
  }
}
