import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/now_playing_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/screens/lyrics_screen.dart';
import 'package:seoulfm/ui/share.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:share_plus/share_plus.dart';

/// Whether a share sheet is up (a screenshot while it is shouldn't open another).
bool shareSheetOpen = false;

/// Spotify's share sheet: a card to share as an image (the song, or a few lines of its
/// lyrics), and ways to send it. [lyricsFirst] opens on the lyrics card when there are lyrics.
Future<void> showShareSheet(
  BuildContext context, {
  required Track track,
  required Color color,
  Lyrics? lyrics,
  bool lyricsFirst = false,
}) async {
  if (shareSheetOpen) return;
  shareSheetOpen = true;
  final position = context.read<NowPlayingController>().positionMs();
  try {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1C),
      builder: (_) => Theme(
        data: buildTheme(Brightness.dark, color),
        child: _ShareSheet(track: track, color: color, lyrics: lyrics, lyricsFirst: lyricsFirst, positionMs: position),
      ),
    );
  } finally {
    shareSheetOpen = false;
  }
}

enum _Card { song, lyrics }

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.track, required this.color, this.lyrics, required this.lyricsFirst, this.positionMs});
  final Track track;
  final Color color;
  final Lyrics? lyrics;
  final bool lyricsFirst;
  final int? positionMs;
  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  static const _maxLines = 6;
  final _card = GlobalKey();
  late final List<String> _lines = _linesOf(widget.lyrics);
  late _Card _mode = widget.lyricsFirst && _lines.isNotEmpty ? _Card.lyrics : _Card.song;
  late List<int> _picked = _defaultPick();
  bool _copied = false;
  bool _busy = false;

  /// Every line worth quoting: synced lines, or the plain text's lines.
  static List<String> _linesOf(Lyrics? l) {
    if (l == null) return const [];
    final raw = l.synced ? l.lines.map((x) => x.text) : (l.plain ?? '').split('\n');
    return raw.map((s) => s.trim()).toList();
  }

  /// The line being sung (or the first line with words), plus the next if it is short.
  List<int> _defaultPick() {
    if (_lines.isEmpty) return const [];
    var i = widget.lyrics!.synced ? activeLyricLine(widget.lyrics!, widget.positionMs) : -1;
    if (i < 0 || _lines[i].isEmpty) i = _lines.indexWhere((s) => s.isNotEmpty);
    if (i < 0) return const [];
    final pick = [i];
    if (_lines[i].length < 28 && i + 1 < _lines.length && _lines[i + 1].isNotEmpty) pick.add(i + 1);
    return pick;
  }

  String get _link => shareLink(songUrl(widget.track), _mode == _Card.lyrics ? 'lyrics' : 'song');

  Rect? _origin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _link));
    setState(() => _copied = true);
  }

  /// The card as a PNG, at three times its on-screen size.
  Future<Uint8List?> _render() async {
    final boundary = _card.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Future<void> _shareImage(BuildContext button) async {
    if (_busy) return;
    setState(() => _busy = true);
    final origin = _origin(button);
    try {
      final png = await _render();
      if (png == null) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(png, mimeType: 'image/png', name: 'seoulfm-${_mode.name}.png')],
          text: _link,
          sharePositionOrigin: origin,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareLink(BuildContext button) => SharePlus.instance.share(
    ShareParams(
      text: '${context.l.shareSong(widget.track.displayTitle, widget.track.displayArtist)}\n$_link',
      sharePositionOrigin: _origin(button),
    ),
  );

  Future<void> _editLines() async {
    final picked = await showModalBottomSheet<List<int>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1C),
      builder: (_) => Theme(
        data: Theme.of(context),
        child: _LinePicker(lines: _lines, picked: _picked, max: _maxLines, color: widget.color),
      ),
    );
    if (picked != null && picked.isNotEmpty) setState(() => _picked = picked);
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final hasLyrics = _lines.any((s) => s.isNotEmpty);
    return Padding(
      padding: EdgeInsets.only(bottom: pad.bottom + 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(9)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: RepaintBoundary(
              key: _card,
              child: AnimatedSwitcher(
                duration: Motion.base,
                child: _mode == _Card.lyrics
                    ? _LyricsCard(
                        key: ValueKey(_picked.join(',')),
                        track: widget.track,
                        color: widget.color,
                        lines: [for (final i in _picked) _lines[i]],
                      )
                    : _SongCard(key: const ValueKey('song'), track: widget.track, color: widget.color),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (hasLyrics)
            PillSegmented<_Card>(
              options: {_Card.song: context.l.shareCardSong, _Card.lyrics: context.l.lyrics},
              selected: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
          if (hasLyrics && _mode == _Card.lyrics)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: OutlinedButton.icon(
                onPressed: _editLines,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(context.l.editLyrics),
              ),
            ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Action(
                icon: _copied ? Icons.check_rounded : Icons.link_rounded,
                label: _copied ? context.l.linkCopied : context.l.copyLink,
                onTap: (_) => _copyLink(),
              ),
              _Action(
                icon: Icons.image_outlined,
                label: context.l.shareImage,
                busy: _busy,
                onTap: _shareImage,
              ),
              _Action(icon: Icons.more_horiz_rounded, label: context.l.tabMore, onTap: _shareLink),
            ],
          ),
        ],
      ),
    );
  }
}

/// A round share target with its name under it.
class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap, this.busy = false});
  final IconData icon;
  final String label;
  final void Function(BuildContext button) onTap;
  final bool busy;
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (button) => InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: () => onTap(button),
        child: SizedBox(
          width: 96,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: busy
                    ? const Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cards (what the image looks like) ──────────────────────────────────────

/// "seoul" heavy, "fm" light: the wordmark that signs every card.
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Text.rich(
    const TextSpan(
      children: [
        TextSpan(
          text: 'seoul',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        TextSpan(
          text: 'fm',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
      ],
    ),
    style: TextStyle(color: color, fontSize: 20, letterSpacing: -0.6),
  );
}

class _SongCard extends StatelessWidget {
  const _SongCard({super.key, required this.track, required this.color});
  final Track track;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final fg = readableOn(color);
    return AspectRatio(
      aspectRatio: 0.8,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Radii.lg)),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [BoxShadow(color: Color(0x59000000), blurRadius: 24, offset: Offset(0, 10))],
                    ),
                    child: Artwork(track.artworkUrl, radius: Radii.md, iconSize: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              track.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: fg, letterSpacing: -0.4),
            ),
            Text(
              track.displayArtist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: fg.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 14),
            _Wordmark(color: fg),
          ],
        ),
      ),
    );
  }
}

class _LyricsCard extends StatelessWidget {
  const _LyricsCard({super.key, required this.track, required this.color, required this.lines});
  final Track track;
  final Color color;
  final List<String> lines;
  @override
  Widget build(BuildContext context) {
    final fg = readableOn(color) == Colors.white ? const Color(0xFF09090B) : readableOn(color);
    final text = lines.join('\n');
    // Fewer words, bigger type.
    final size = text.length < 50 ? 30.0 : (text.length < 110 ? 25.0 : 20.0);
    return AspectRatio(
      aspectRatio: 0.8,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Radii.lg)),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Artwork(track.artworkUrl, size: 44, radius: 6),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg),
                      ),
                      Text(
                        track.displayArtist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: fg.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: size,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: fg,
                  fontFamilyFallback: const ['Pretendard', 'Apple SD Gothic Neo', 'Noto Sans KR'],
                ),
              ),
            ),
            _Wordmark(color: fg),
          ],
        ),
      ),
    );
  }
}

// ── Picking lines ──────────────────────────────────────────────────────────

class _LinePicker extends StatefulWidget {
  const _LinePicker({required this.lines, required this.picked, required this.max, required this.color});
  final List<String> lines;
  final List<int> picked;
  final int max;
  final Color color;
  @override
  State<_LinePicker> createState() => _LinePickerState();
}

class _LinePickerState extends State<_LinePicker> {
  late final Set<int> _picked = {...widget.picked};

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l.editLyrics, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(context.l.pickLines(widget.max), style: TextStyle(fontSize: 13, color: c.muted)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _picked.isEmpty ? null : () => Navigator.pop(context, _picked.toList()..sort()),
                  child: Text(context.l.done),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemCount: widget.lines.length,
              itemBuilder: (_, i) {
                final text = widget.lines[i];
                if (text.isEmpty) return const SizedBox(height: 12);
                final on = _picked.contains(i);
                final full = !on && _picked.length >= widget.max;
                return InkWell(
                  onTap: full ? null : () => setState(() => on ? _picked.remove(i) : _picked.add(i)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: on ? widget.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: on ? readableOn(widget.color) : (full ? c.faint : c.text),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
