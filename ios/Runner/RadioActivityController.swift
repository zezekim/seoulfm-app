import ActivityKit
import Foundation
import UIKit

/// The Live Activity, only while the listener's request is on its way: its countdown, then
/// "Playing now". The rest of the time iOS's own Now Playing has the Dynamic Island and the lock
/// screen (the cover, a waveform, every song), as Apple Music and Spotify leave it: an activity
/// of our own beside it only squeezes into a stale circle. Fed by what the app sends the widgets
/// (`HomeWidgets` in Dart).
@available(iOS 16.2, *)
final class RadioActivityController {
  static let shared = RadioActivityController()

  /// An activity left by an earlier run (the app was closed while one showed) can't be updated
  /// any more: end it, rather than leave it frozen on the island.
  private init() {
    Task {
      for old in Activity<RadioActivityAttributes>.activities { await old.end(nil, dismissalPolicy: .immediate) }
    }
  }
  private var activity: Activity<RadioActivityAttributes>?
  private var artFor: String?
  private var artFile: String?
  private var pauseEnd: DispatchWorkItem?
  /// The last state shown, so a request change can redraw it.
  private var last: RadioActivityAttributes.ContentState?
  private var request: (title: String, at: Date?, playing: Bool)?
  /// When the current request's countdown began (the ring's start), per request title.
  private var requestSince: (title: String, at: Date)?

  /// The listener's request on its way (`HomeWidgets.request` in Dart), or nil once it has
  /// played or gone: it starts the activity, keeps it current, and its end ends it.
  func setRequest(_ data: [String: Any]?) {
    if let data, let title = data["title"] as? String {
      let at = (data["at"] as? NSNumber).map { Date(timeIntervalSince1970: $0.doubleValue) }
      request = (title, at, data["playing"] as? Bool ?? false)
      if requestSince?.title != title { requestSince = (title, Date()) }
      if let last { apply(last) }
    } else {
      request = nil
      end()
    }
  }

  func update(_ data: [String: Any]) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    let playing = data["playing"] as? Bool ?? false
    let artUrl = data["artUrl"] as? String
    var state = RadioActivityAttributes.ContentState(
      station: data["stationName"] as? String ?? "SeoulFM",
      title: data["title"] as? String,
      artist: data["artist"] as? String,
      playing: playing,
      accent: (data["accent"] as? NSNumber)?.intValue ?? 0,
      artFile: artUrl == artFor ? artFile : nil)

    pauseEnd?.cancel()
    if playing {
      apply(state)
    } else if activity != nil {
      apply(state)
      // Paused: leave it on the lock screen for 15 minutes, then end it.
      let end = DispatchWorkItem { [weak self] in self?.end() }
      pauseEnd = end
      DispatchQueue.main.asyncAfter(deadline: .now() + 15 * 60, execute: end)
    } else {
      last = state  // what a request's activity will open with
    }

    // A new song: save a small cover where the extension can read it, then update again.
    if let artUrl, artUrl != artFor, let url = URL(string: artUrl) {
      artFor = artUrl
      URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
        guard let self, let data, let image = UIImage(data: data) else { return }
        // Exactly 160 px: drawn at the screen's 3x scale it was 480 px, which a Live Activity
        // can't render (the island and lock screen then show it blank).
        let size = CGSize(width: 160, height: 160)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let small = UIGraphicsImageRenderer(size: size, format: format).jpegData(withCompressionQuality: 0.8) { _ in
          image.draw(in: CGRect(origin: .zero, size: size))
        }
        let name = "activity-\(abs(artUrl.hashValue)).jpg"
        guard let file = RadioActivityArt.url(name), (try? small.write(to: file)) != nil else { return }
        DispatchQueue.main.async {
          guard self.artFor == artUrl else { return }
          if let old = self.artFile, old != name, let oldUrl = RadioActivityArt.url(old) {
            try? FileManager.default.removeItem(at: oldUrl)
          }
          self.artFile = name
          state.artFile = name
          if self.activity != nil { self.apply(state) }
        }
      }.resume()
    }
  }

  private func apply(_ base: RadioActivityAttributes.ContentState) {
    last = base
    var state = base
    state.requestTitle = request?.title
    state.requestAt = request?.at
    state.requestPlaying = request?.playing
    state.requestSince = request == nil ? nil : requestSince?.at
    let content = ActivityContent(state: state, staleDate: nil)
    if let activity, activity.activityState == .active {
      Task { await activity.update(content) }
    } else if request != nil, ActivityAuthorizationInfo().areActivitiesEnabled {
      activity = try? Activity.request(attributes: RadioActivityAttributes(), content: content)
    }
  }

  private func end() {
    guard let activity else { return }
    self.activity = nil
    Task { await activity.end(nil, dismissalPolicy: .immediate) }
  }
}
