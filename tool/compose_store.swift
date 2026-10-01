// Frames raw store captures (tool/store_screenshots.sh) as store images: a two-line headline over
// a dark backdrop tinted from the screen's own colours, the screen below with rounded corners and
// a soft shadow. Text is set by the system, so every script (Arabic, Thai, CJK) shapes properly.
//
//   swift tool/compose_store.swift <raw dir> <out dir> <tag> [WxH]
//   swift tool/compose_store.swift --feature <out.png> <tag>
//
// Headlines come from store/captions/<tag>.json. WxH sets the canvas (Google Play wants at most
// 2:1, e.g. 1080x1920); without it the canvas is the capture's size. --feature draws Google
// Play's 1024 x 500 feature graphic.
import AppKit
import CoreText
import SwiftUI

let repo = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
CTFontManagerRegisterFontsForURL(repo.appendingPathComponent("assets/fonts/PretendardVariable.ttf") as CFURL, .process, nil)

/// The headline face: Pretendard (the app's) where it covers the script, else the system's
/// face for that language, so a line never mixes two designs.
func headlineFont(_ tag: String, _ size: CGFloat) -> Font {
  switch tag {
  case "ja": return .custom("HiraginoSans-W8", fixedSize: size)
  case "zh": return .custom("PingFangSC-Semibold", fixedSize: size)
  case "zh-Hant": return .custom("PingFangTC-Semibold", fixedSize: size)
  case "ar", "th": return .system(size: size, weight: .heavy)
  default: return .custom("Pretendard Variable", fixedSize: size).weight(.heavy)
  }
}

func captions(_ tag: String) -> [String: [String]] {
  let url = repo.appendingPathComponent("store/captions/\(tag).json")
  guard let data = try? Data(contentsOf: url), let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String]]
  else { fatalError("no captions for \(tag) at \(url.path)") }
  return json
}

/// The screen's most colourful pixel (of a 24 x 52 thumbnail), darkened for a backdrop.
func backdropTint(_ image: CGImage) -> Color {
  let w = 24, h = 52
  var px = [UInt8](repeating: 0, count: w * h * 4)
  let ctx = CGContext(data: &px, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
  var best: (Double, Double, Double) = (40, 40, 48)
  var score = -1.0
  for i in stride(from: 0, to: px.count, by: 4) {
    let r = Double(px[i]), g = Double(px[i + 1]), b = Double(px[i + 2])
    let mx = max(r, g, b), mn = min(r, g, b)
    let s = (mx - mn) / 255 * (1 - abs((mx + mn) / 510 - 0.5))
    if s > score { best = (r, g, b); score = s }
  }
  return Color(red: best.0 * 0.42 / 255, green: best.1 * 0.42 / 255, blue: best.2 * 0.42 / 255)
}

struct Shot: View {
  let screen: CGImage
  let lines: [String]
  let tag: String
  let size: CGSize
  let fit: Bool

  var body: some View {
    let W = size.width, H = size.height
    let unit = min(W, H / 2.17)
    let fontSize = unit * 0.082
    let top = H * 0.055
    let headline = unit * 0.1 * 2
    let gap = H * 0.035
    let room = H - (top + headline + gap) - H * 0.02
    let sw0 = CGFloat(screen.width), sh0 = CGFloat(screen.height)
    let k = fit ? min(W * 0.8 / sw0, room / sh0) : 0.8 * W / sw0
    let sw = sw0 * k, sh = sh0 * k
    // Rounded like the device: a phone's corners are far rounder than an iPad's.
    let radius = sw * (sh0 / sw0 > 1.6 ? 0.11 : 0.045)
    ZStack(alignment: .top) {
      LinearGradient(colors: [backdropTint(screen), Color(red: 10 / 255, green: 10 / 255, blue: 11 / 255)],
                     startPoint: .top, endPoint: .bottom)
      VStack(spacing: 0) {
        ForEach(Array(lines.enumerated()), id: \.offset) { i, line in
          Text(line)
            .font(headlineFont(tag, fontSize))
            .foregroundStyle(i == 0 ? Color.white : Color(red: 215 / 255, green: 215 / 255, blue: 220 / 255))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(width: W * 0.9, height: unit * 0.1)
        }
      }
      .padding(.top, top)
      Image(decorative: screen, scale: 1)
        .resizable()
        .frame(width: sw, height: sh)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(.white.opacity(0.16), lineWidth: 3))
        .shadow(color: .black.opacity(0.67), radius: 60, y: 30)
        .padding(.top, top + headline + gap)
    }
    .frame(width: W, height: H)
    .environment(\.layoutDirection, tag == "ar" ? .rightToLeft : .leftToRight)
  }
}

/// Google Play's feature graphic: the icon and the tagline on Pop!'s colour.
struct Feature: View {
  let icon: NSImage
  let lines: [String]
  let tag: String
  var body: some View {
    ZStack {
      LinearGradient(colors: [Color(red: 1, green: 0.23, blue: 0.36), Color(red: 0.16, green: 0.03, blue: 0.07)],
                     startPoint: .topLeading, endPoint: .bottomTrailing)
      RadialGradient(colors: [.white.opacity(0.18), .clear], center: .topLeading, startRadius: 0, endRadius: 700)
      HStack(spacing: 44) {
        Image(nsImage: icon).resizable().frame(width: 240, height: 240)
          .clipShape(RoundedRectangle(cornerRadius: 54, style: .continuous))
          .shadow(color: .black.opacity(0.45), radius: 30, y: 14)
        VStack(alignment: .leading, spacing: 14) {
          Text(lines[0]).font(headlineFont(tag, 50)).foregroundStyle(.white)
            .lineLimit(2).minimumScaleFactor(0.6).fixedSize(horizontal: false, vertical: true)
          Text(lines[1]).font(headlineFont(tag, 24)).foregroundStyle(.white.opacity(0.78))
            .lineLimit(2).minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.horizontal, 64)
    }
    .frame(width: 1024, height: 500)
    .environment(\.layoutDirection, tag == "ar" ? .rightToLeft : .leftToRight)
  }
}

@MainActor func render(_ view: some View, to url: URL) {
  let r = ImageRenderer(content: view)
  r.scale = 1
  guard let cg = r.cgImage else { fatalError("render failed: \(url.lastPathComponent)") }
  // Store images must be opaque: flatten onto black, no alpha channel.
  let ctx = CGContext(data: nil, width: cg.width, height: cg.height, bitsPerComponent: 8, bytesPerRow: 0,
                      space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
  ctx.setFillColor(.black)
  ctx.fill(CGRect(x: 0, y: 0, width: cg.width, height: cg.height))
  ctx.draw(cg, in: CGRect(x: 0, y: 0, width: cg.width, height: cg.height))
  let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
  try! rep.representation(using: .png, properties: [:])!.write(to: url)
}

@MainActor func main() {
  var args = Array(CommandLine.arguments.dropFirst())
  if args.first == "--feature" {
    guard args.count == 3 else { fatalError("usage: --feature <out.png> <tag>") }
    let icon = NSImage(contentsOf: repo.appendingPathComponent("assets/icon/app-icon-1024.png"))!
    let lines = captions(args[2])["feature"]!
    render(Feature(icon: icon, lines: lines, tag: args[2]), to: URL(fileURLWithPath: args[1]))
    print("feature \(args[2])")
    return
  }
  guard args.count >= 3 else { fatalError("usage: <raw dir> <out dir> <tag> [WxH]") }
  let raw = URL(fileURLWithPath: args.removeFirst()), out = URL(fileURLWithPath: args.removeFirst())
  let tag = args.removeFirst()
  let canvas = args.first.map { s -> CGSize in
    let p = s.split(separator: "x").compactMap { Double($0) }
    return CGSize(width: p[0], height: p[1])
  }
  try? FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
  let caps = captions(tag)
  let files = (try? FileManager.default.contentsOfDirectory(atPath: raw.path)) ?? []
  for file in files.sorted() where file.hasPrefix("\(tag)-") && file.hasSuffix(".png") {
    // "<tag>-3-lyrics.png" -> "3-lyrics" (a tag like zh-Hant has its own dash).
    let key = String(file.dropFirst(tag.count + 1).dropLast(4))
    guard key.first?.isNumber == true, let lines = caps[key] else { continue }
    guard let src = NSImage(contentsOf: raw.appendingPathComponent(file))?.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else { continue }
    let size = canvas ?? CGSize(width: src.width, height: src.height)
    render(Shot(screen: src, lines: lines, tag: tag, size: size, fit: canvas != nil), to: out.appendingPathComponent(file))
    print("composed \(file)")
  }
}

MainActor.assumeIsolated { main() }
