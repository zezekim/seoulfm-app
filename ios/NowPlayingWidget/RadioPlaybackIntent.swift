import AppIntents
import Foundation

/// What Siri, Shortcuts and Control Center ask the radio to do. The app hands these to Dart
/// (`IntentBridge` in the app); in the widget extension nothing is listening, which is fine:
/// the system runs audio intents in the app's process, never in the extension's.
enum RadioCommand {
  case play(station: String)
  case resume
  case pause
}

enum RadioCommands {
  /// Set by the app at launch. Returns once the radio has acted (or given up).
  static var handler: ((RadioCommand) async -> Void)?

  static func run(_ command: RadioCommand) async {
    await handler?(command)
  }
}

/// Control Center's play/pause. Compiled into both the app and the extension: the control
/// names it from the extension, and as an `AudioPlaybackIntent` it runs in the app, which
/// owns the player (launched in the background if it isn't running).
@available(iOS 18.0, *)
struct ToggleRadioIntent: SetValueIntent, AudioPlaybackIntent {
  static let title: LocalizedStringResource = "Play or Pause SeoulFM"
  static let isDiscoverable = false

  @Parameter(title: "Playing")
  var value: Bool

  init() {}

  @MainActor
  func perform() async throws -> some IntentResult {
    await RadioCommands.run(value ? .resume : .pause)
    return .result()
  }
}
