import ActivityKit
import SwiftUI
import WidgetKit

/// The lock screen and Dynamic Island while a station plays: the cover, the song, the station
/// in its colour, and a waveform while it plays. Tapping opens the app.
struct RadioLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: RadioActivityAttributes.self) { context in
      LockScreenView(state: context.state)
        .activityBackgroundTint(Color(red: 0.07, green: 0.07, blue: 0.08))
        .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      let s = context.state
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Cover(file: s.artFile, accent: s.accent).frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        DynamicIslandExpandedRegion(.trailing) {
          Wave(playing: s.playing, accent: s.accent).frame(height: 52)
        }
        DynamicIslandExpandedRegion(.center) {
          VStack(alignment: .leading, spacing: 2) {
            Text(s.title ?? s.station).font(.system(size: 15, weight: .bold)).lineLimit(1)
            Text(s.artist ?? "").font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(1)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(s.station.uppercased()).font(.system(size: 10, weight: .bold)).kerning(1.2)
            .foregroundStyle(argbColor(s.accent)).frame(maxWidth: .infinity, alignment: .leading)
        }
      } compactLeading: {
        Cover(file: s.artFile, accent: s.accent).frame(width: 24, height: 24).clipShape(Circle())
      } compactTrailing: {
        Wave(playing: s.playing, accent: s.accent).frame(width: 22, height: 16)
      } minimal: {
        Cover(file: s.artFile, accent: s.accent).frame(width: 24, height: 24).clipShape(Circle())
      }
      .keylineTint(argbColor(s.accent))
    }
  }
}

private func argbColor(_ argb: Int) -> Color {
  guard argb != 0 else { return Color(red: 1, green: 0.23, blue: 0.36) }
  return Color(red: Double((argb >> 16) & 0xFF) / 255, green: Double((argb >> 8) & 0xFF) / 255, blue: Double(argb & 0xFF) / 255)
}

private struct Cover: View {
  let file: String?
  let accent: Int
  var body: some View {
    if let file, let url = RadioActivityArt.url(file), let image = UIImage(contentsOfFile: url.path) {
      Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
    } else {
      ZStack {
        argbColor(accent).opacity(0.4)
        Image(systemName: "radio").foregroundStyle(.white.opacity(0.8))
      }
    }
  }
}

private struct Wave: View {
  let playing: Bool
  let accent: Int
  var body: some View {
    Image(systemName: playing ? "waveform" : "pause.fill")
      .font(.system(size: 16, weight: .bold))
      .foregroundStyle(argbColor(accent))
      .symbolEffect(.variableColor.iterative, isActive: playing)
  }
}

private struct LockScreenView: View {
  let state: RadioActivityAttributes.ContentState
  var body: some View {
    HStack(spacing: 14) {
      Cover(file: state.artFile, accent: state.accent).frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      VStack(alignment: .leading, spacing: 2) {
        Text(state.station.uppercased()).font(.system(size: 10, weight: .bold)).kerning(1.2)
          .foregroundStyle(argbColor(state.accent)).lineLimit(1)
        Text(state.title ?? "SeoulFM").font(.system(size: 16, weight: .bold)).foregroundStyle(.white).lineLimit(1)
        Text(state.artist ?? "").font(.system(size: 13)).foregroundStyle(.white.opacity(0.7)).lineLimit(1)
      }
      Spacer(minLength: 0)
      Wave(playing: state.playing, accent: state.accent)
    }
    .padding(16)
  }
}
