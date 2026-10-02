import AppIntents
import SwiftUI
import WidgetKit

/// Control Center (and the Lock Screen's and Action button's controls): play or pause the
/// radio. The intent runs in the app, which reloads this control when the play state changes.
@available(iOS 18.0, *)
struct PlaybackControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "PlaybackControl", provider: Provider()) { playing in
      ControlWidgetToggle("SeoulFM", isOn: playing, action: ToggleRadioIntent()) { on in
        Label(on ? LocalizedStringKey("Playing") : LocalizedStringKey("Paused"), systemImage: on ? "pause.fill" : "play.fill")
      }
      .tint(Color(red: 1, green: 0.23, blue: 0.36))
    }
    .displayName("Play SeoulFM")
    .description("Plays or pauses the radio.")
  }

  /// What the app last said (the App Group). Without the group (free-team builds) it reads
  /// as paused, and a tap plays.
  struct Provider: ControlValueProvider {
    var previewValue: Bool { false }

    func currentValue() async throws -> Bool {
      UserDefaults(suiteName: appGroup)?.bool(forKey: "playing") ?? false
    }
  }
}
