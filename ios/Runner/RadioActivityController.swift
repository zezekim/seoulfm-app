import ActivityKit
import Foundation
import UIKit

/// Starts, updates and ends the Live Activity from what the app sends the widgets
/// (`HomeWidgets` in Dart): one activity while a station plays, kept for a while after a
/// pause so resuming picks it back up.
@available(iOS 16.2, *)
final class RadioActivityController {
  static let shared = RadioActivityController()
  private var activity: Activity<RadioActivityAttributes>?
  private var artFor: String?
  private var artFile: String?
  private var pauseEnd: DispatchWorkItem?
  /// The last state shown, so a request change can redraw it.
  private var last: RadioActivityAttributes.ContentState?
  private var request: (title: String, at: Date?, playing: Bool)?

  /// The listener's request on its way (`HomeWidgets.request` in Dart), or nil once it has
  /// played or gone. Shown on the activity while there is one; never starts one by itself.
  func setRequest(_ data: [String: Any]?) {
    if let data, let title = data["title"] as? String {
      let at = (data["at"] as? NSNumber).map { Date(timeIntervalSince1970: $0.doubleValue) }
      request = (title, at, data["playing"] as? Bool ?? false)
    } else {
      request = nil
    }
    if let last, activity != nil { apply(last) }
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
    }

    // A new song: save a small cover where the extension can read it, then update again.
    if let artUrl, artUrl != artFor, let url = URL(string: artUrl) {
      artFor = artUrl
      URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
        guard let self, let data, let image = UIImage(data: data) else { return }
        let size = CGSize(width: 160, height: 160)
        let small = UIGraphicsImageRenderer(size: size).jpegData(withCompressionQuality: 0.8) { _ in
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
    let content = ActivityContent(state: state, staleDate: nil)
    if let activity, activity.activityState == .active {
      Task { await activity.update(content) }
    } else if state.playing {
      activity = try? Activity.request(attributes: RadioActivityAttributes(), content: content)
    }
  }

  private func end() {
    guard let activity else { return }
    self.activity = nil
    last = nil
    Task { await activity.end(nil, dismissalPolicy: .immediate) }
  }
}
