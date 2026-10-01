import 'package:flutter/material.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';

/// Covers to request from (`RequestGrid`) as a shelf: random songs from the tuned
/// station's library, spread so the same artist never sits close together.
/// Tap to request, long-press for the song page.
class RequestShelf extends StatefulWidget {
  const RequestShelf({super.key});
  @override
  State<RequestShelf> createState() => _RequestShelfState();
}

class _RequestShelfState extends State<RequestShelf> {
  late Future<List<Track>> _f = _load();

  Future<List<Track>> _load() async =>
      spreadByArtist((await api.random(limit: 24)).where((t) => t.requestable != false).toList());

  static const _cover = 132.0;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShelfTitle(
          context.l.requestASong,
          subtitle: context.l.requestHint,
          trailing: IconButton(
            tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            onPressed: () => setState(() {
              _f = _load();
            }),
            icon: Icon(Icons.shuffle_rounded, size: 20, color: c.muted),
          ),
        ),
        SizedBox(
          height: _cover + 54,
          child: FutureBuilder<List<Track>>(
            future: _f,
            builder: (context, s) {
              if (s.hasError) {
                return ErrorRetry(
                  onRetry: () => setState(() {
                    _f = _load();
                  }),
                );
              }
              final items = s.data;
              if (items == null) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, _) => const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: _cover, height: _cover, radius: Radii.md),
                      SizedBox(height: 10),
                      Skeleton(width: 100, height: 12, radius: 4),
                      SizedBox(height: 6),
                      Skeleton(width: 70, height: 10, radius: 4),
                    ],
                  ),
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final t = items[i];
                  return Pressable(
                    onTap: () => showRequestSheet(context, t),
                    onLongPress: () => Nav.openSong(t),
                    child: SizedBox(
                      width: _cover,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Artwork(t.artworkUrl, size: _cover, radius: Radii.md),
                          const SizedBox(height: 8),
                          Text(
                            t.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            t.displayArtist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: c.muted),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Same-artist tracks at least three apart (`spreadByArtist` in RequestGrid.tsx).
List<Track> spreadByArtist(List<Track> input, {int gap = 3}) {
  final pool = [...input];
  final out = <Track>[];
  while (pool.isNotEmpty) {
    final recent = out.reversed.take(gap).map((t) => t.artist).toSet();
    final i = pool.indexWhere((t) => !recent.contains(t.artist));
    out.add(pool.removeAt(i < 0 ? 0 : i));
  }
  return out;
}
