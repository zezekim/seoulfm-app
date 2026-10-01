import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/ui/widgets/dedication_actions.dart';
import 'package:seoulfm/state/moderation.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// Listeners' dedications on the tuned station (the request wall).
class WallScreen extends StatefulWidget {
  const WallScreen({super.key});
  @override
  State<WallScreen> createState() => _WallScreenState();
}

class _WallScreenState extends State<WallScreen> {
  String? _station;
  Future<List<WallItem>>? _f;

  @override
  Widget build(BuildContext context) {
    final station = context.watch<ChannelController>().active;
    if (_station != station.key) {
      _station = station.key;
      _f = api.wall(limit: 60);
    }
    final c = context.sfm;
    return Scaffold(
      appBar: AppBar(title: Text('${context.l.tabWall} · ${station.name}')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _f = api.wall(limit: 60);
          });
          await _f;
        },
        child: FutureBuilder<List<WallItem>>(
          future: _f,
          builder: (context, s) {
            if (s.hasError) {
              return ListView(
                children: [
                  ErrorRetry(
                    error: s.error,
                    onRetry: () => setState(() {
                      _f = api.wall(limit: 60);
                    }),
                  ),
                ],
              );
            }
            if (!s.hasData) return const SingleChildScrollView(child: SkeletonList());
            final moderation = context.watch<Moderation>();
            final items = s.data!.where((w) => w.dedication != null && !moderation.hides(w.dedication, entryId: w.entryId)).toList();
            if (items.isEmpty) {
              return ListView(
                children: [
                  EmptyState(icon: AppIcons.dedications, title: context.l.wallEmptyTitle, body: context.l.dedicationsEmpty),
                ],
              );
            }
            return ListView.separated(
              padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, MediaQuery.paddingOf(context).bottom + 16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final w = items[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(Radii.lg),
                  onTap: () => Nav.openSong(w.track),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.surface,
                      border: Border.all(color: c.border),
                      borderRadius: BorderRadius.circular(Radii.lg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Artwork(w.track.artworkUrl, size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.track.displayTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  Text(
                                    w.track.displayArtist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: c.muted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(timeAgo(context, w.requestedAtEpoch), style: TextStyle(fontSize: 11, color: c.faint)),
                            // Compact to look, but still a full-size tap target (a 32 pt box was too small to hit).
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: context.l.moreOptions,
                              icon: Icon(AppIcons.more, size: 18, color: c.muted),
                              onPressed: () => showDedicationActions(context, dedication: w.dedication!, track: w.track, entryId: w.entryId),
                            ),
                          ],
                        ),
                        if (w.dedication!.message != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '“${w.dedication!.message!}”',
                            style: const TextStyle(fontSize: 14, height: 1.4, fontStyle: FontStyle.italic),
                          ),
                        ],
                        if (w.dedication!.name != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '— ${w.dedication!.name!}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: station.color),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
