import SwiftUI
import WidgetKit

/// Shared with the app (`HomeWidgets` in Dart writes it through AppDelegate).
let appGroup = "group.com.seoulfm.seoulfm"

struct NowPlayingEntry: TimelineEntry {
  let date: Date
  let station: String
  let title: String?
  let artist: String?
  let art: UIImage?
  let accent: Color
  let playing: Bool
  /// When to look again: the song's end if known.
  let refreshAt: Date

  static let sample = NowPlayingEntry(
    date: .now, station: "SeoulFM Pop!", title: "Now playing", artist: "SeoulFM", art: nil,
    accent: Color(red: 1, green: 0.23, blue: 0.36), playing: true, refreshAt: .now.addingTimeInterval(300))
}

/// What the app last said is on air; when that is old (the app isn't running), the widget asks
/// the API itself for the station's now playing.
struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> NowPlayingEntry { .sample }

  func getSnapshot(in context: Context, completion: @escaping (NowPlayingEntry) -> Void) {
    if context.isPreview { return completion(.sample) }
    Task { completion(await load()) }
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<NowPlayingEntry>) -> Void) {
    Task {
      let entry = await load()
      completion(Timeline(entries: [entry], policy: .after(entry.refreshAt)))
    }
  }

  private func load() async -> NowPlayingEntry {
    let d = UserDefaults(suiteName: appGroup)
    let station = d?.string(forKey: "stationName") ?? "SeoulFM Pop!"
    let accent = color(argb: d?.integer(forKey: "accent") ?? 0)
    let playing = d?.bool(forKey: "playing") ?? false
    var title = d?.string(forKey: "title")
    var artist = d?.string(forKey: "artist")
    var artURL = d?.string(forKey: "artUrl")
    var refreshAt = Date.now.addingTimeInterval(15 * 60)

    // Stale (or never written): ask the API, as the app would.
    let savedAt = d?.double(forKey: "savedAt") ?? 0
    if Date.now.timeIntervalSince1970 - savedAt > 10 * 60, let fresh = await fetch(d) {
      title = fresh.title
      artist = fresh.artist
      artURL = fresh.art
      if let ends = fresh.endsAt { refreshAt = max(ends.addingTimeInterval(5), .now.addingTimeInterval(60)) }
    }
    return NowPlayingEntry(
      date: .now, station: station, title: title, artist: artist, art: await image(artURL), accent: accent,
      playing: playing, refreshAt: refreshAt)
  }

  private struct Fresh {
    let title: String?, artist: String?, art: String?, endsAt: Date?
  }

  private func fetch(_ d: UserDefaults?) async -> Fresh? {
    guard let d, let base = d.string(forKey: "apiBase"), let key = d.string(forKey: "apiKey"), !key.isEmpty,
      let url = URL(string: "\(base)/now-playing?station=\(d.string(forKey: "stationKey") ?? "seoulfm")")
    else { return nil }
    var req = URLRequest(url: url, timeoutInterval: 10)
    req.setValue(key, forHTTPHeaderField: "X-API-Key")
    guard let (data, _) = try? await URLSession.shared.data(for: req),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }
    let current = json["current"] as? [String: Any]
    var art = current?["artwork_url"] as? String
    // The app's rewrite: CDN covers come from the site's copies.
    if let a = art, let cdn = d.string(forKey: "artCdn"), let site = d.string(forKey: "siteUrl"), a.hasPrefix(cdn) {
      art = "\(site)/api/art/\(a.dropFirst(cdn.count))"
    }
    let ends = (json["ends_at_epoch"] as? NSNumber).map { Date(timeIntervalSince1970: $0.doubleValue) }
    return Fresh(title: current?["title"] as? String, artist: current?["artist"] as? String, art: art, endsAt: ends)
  }

  private func image(_ string: String?) async -> UIImage? {
    guard let string, let url = URL(string: string),
      let (data, _) = try? await URLSession.shared.data(from: url), let image = UIImage(data: data)
    else { return nil }
    // Widgets have a small memory budget: keep the cover small.
    let size = CGSize(width: 300, height: 300)
    return UIGraphicsImageRenderer(size: size).image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
  }

  private func color(argb: Int) -> Color {
    guard argb != 0 else { return Color(red: 1, green: 0.23, blue: 0.36) }
    return Color(
      red: Double((argb >> 16) & 0xFF) / 255, green: Double((argb >> 8) & 0xFF) / 255, blue: Double(argb & 0xFF) / 255)
  }
}

struct NowPlayingView: View {
  @Environment(\.widgetFamily) var family
  let entry: NowPlayingEntry

  var cover: some View {
    Group {
      if let art = entry.art {
        Image(uiImage: art).resizable().aspectRatio(contentMode: .fill)
      } else {
        ZStack {
          entry.accent.opacity(0.35)
          Image(systemName: "radio").font(.system(size: 28, weight: .semibold)).foregroundStyle(.white.opacity(0.7))
        }
      }
    }
  }

  var text: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(spacing: 5) {
        if entry.playing {
          Image(systemName: "waveform").font(.system(size: 10, weight: .bold)).foregroundStyle(entry.accent)
        }
        Text(entry.station.uppercased()).font(.system(size: 10, weight: .bold)).kerning(1.2)
          .foregroundStyle(entry.accent).lineLimit(1)
      }
      Text(entry.title ?? "Tap to listen").font(.system(size: 16, weight: .bold)).foregroundStyle(.white).lineLimit(1)
      if let artist = entry.artist {
        Text(artist).font(.system(size: 13)).foregroundStyle(.white.opacity(0.7)).lineLimit(1)
      }
    }
  }

  var body: some View {
    switch family {
    case .systemSmall:
      // The cover fills the widget, the song over a shade at the bottom.
      ZStack(alignment: .bottomLeading) {
        LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
        text.padding(12)
      }
      .containerBackground(for: .widget) { cover }
    default:
      HStack(spacing: 14) {
        cover.frame(width: 110, height: 110).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        text
        Spacer(minLength: 0)
      }
      .containerBackground(for: .widget) {
        ZStack {
          Color(red: 0.07, green: 0.07, blue: 0.08)
          LinearGradient(colors: [entry.accent.opacity(0.35), .clear], startPoint: .leading, endPoint: .trailing)
        }
      }
    }
  }
}

/// The extension's widgets: the home-screen widget and the Live Activity.
@main
struct SeoulFMWidgets: WidgetBundle {
  var body: some Widget {
    NowPlayingWidget()
    RadioLiveActivity()
  }
}

struct NowPlayingWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "NowPlaying", provider: Provider()) { NowPlayingView(entry: $0) }
      .configurationDisplayName("SeoulFM")
      .description("What's playing on your station.")
      .supportedFamilies([.systemSmall, .systemMedium])
      .contentMarginsDisabled()
  }
}
