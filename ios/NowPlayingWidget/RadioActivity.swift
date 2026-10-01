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
  }
}

enum RadioActivityArt {
  static let group = "group.com.seoulfm.seoulfm"
  static func url(_ name: String) -> URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)?.appendingPathComponent(name)
  }
}
