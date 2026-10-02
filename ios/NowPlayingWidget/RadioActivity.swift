import ActivityKit
import Foundation

/// The Live Activity's data, shared by the app (which starts and updates it) and the widget
/// extension (which draws it). The cover is a small file in the App Group, not in the payload,
/// which ActivityKit keeps to 4 KB.
struct RadioActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var station: String
    var title: String?
    var artist: String?
    var playing: Bool
    var accent: Int
    /// The cover's file name in the App Group container; changes with the song.
    var artFile: String?
    /// The listener's request on its way: its title, when it should start (nil: not known)
    /// and whether it is playing now. Optional, so states saved before these existed decode.
    var requestTitle: String?
    var requestAt: Date?
    var requestPlaying: Bool?
    /// When the countdown began, for the ring that fills as the request comes up.
    var requestSince: Date?
  }
}

enum RadioActivityArt {
  static let group = "group.com.seoulfm.seoulfm"
  static func url(_ name: String) -> URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)?.appendingPathComponent(name)
  }
}
