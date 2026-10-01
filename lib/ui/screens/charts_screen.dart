import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';
import 'package:seoulfm/ui/icons.dart';

/// Under the collapsing header: clear of the pinned bar (the injector) and of the floating
/// player and tab bar at the bottom.
Widget _injected(BuildContext context, List<Widget> slivers) => CustomScrollView(
  slivers: [
    SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
    ...slivers,
    SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 16)),
  ],
);

Widget _frame(BuildContext context, Widget child) => _injected(context, [SliverToBoxAdapter(child: child)]);

/// The tuned station's charts: the week, hot right now, most requested, trending, artists.
/// A large title that shrinks as the list scrolls, the tabs pinned under it.
class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final station = context.watch<ChannelController>().active;
    final l = context.l;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: largeTitleBar(
                context,
                '${l.tabCharts} · ${station.name}',
                bottom: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: station.color,
                  labelColor: context.sfm.text,
                  unselectedLabelColor: context.sfm.muted,
                  dividerColor: context.sfm.border,
                  tabs: [
                    Tab(text: l.chartsWeekly),
                    Tab(text: '🔥 ${l.chartsHot}'),
                    Tab(text: l.chartsRequested),
                    Tab(text: l.chartsTrending),
                    Tab(text: l.artists),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            key: ValueKey(station.key),
            children: [
              _TrackChart(
                load: () => api.weeklyChart(),
                count: (t) => t.playCount == null ? null : l.plays(t.playCount!),
              ),
              _TrackChart(load: () => api.hotTracks()),
              _TrackChart(
                load: () => api.topRequested(),
                count: (t) => t.requestCount == null ? null : l.requestsCount(t.requestCount!),
              ),
              _TrackChart(load: () => api.trending(), count: (t) => t.playCount == null ? null : l.plays(t.playCount!)),
              Builder(
                builder: (context) => Loader<List<ArtistSummary>>(
                  load: () => api.topArtists(),
                  frame: _frame,
                  builder: (context, items) => _injected(context, [
                    SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final a = items[i];
                        return ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: context.sfm.muted,
                                    fontFeatures: tabular,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Artwork(a.artworkUrl, size: 44, radius: 22),
                            ],
                          ),
                          title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            l.plays(a.playCount),
                            style: TextStyle(color: context.sfm.muted, fontSize: 12),
                          ),
                          onTap: () => Nav.openArtist(a.key, name: a.name),
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackChart extends StatelessWidget {
  const _TrackChart({required this.load, this.count});
  final Future<List<Track>> Function() load;
  final String? Function(Track)? count;

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Loader<List<Track>>(
      load: load,
      frame: _frame,
      builder: (context, items) => _injected(context, [
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final t = items[i];
            final pos = t.position ?? i + 1;
            return TrackRow(
              requestable: true,
              track: t,
              onTap: () => Nav.openSong(t),
              subtitle: [t.displayArtist, ?count?.call(t)].join(' · '),
              // The rank, big and bold (the top three in the accent), the movement under it.
              leading: SizedBox(
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$pos',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: pos < 10 ? 20 : 17,
                        letterSpacing: -0.6,
                        height: 1.1,
                        fontFeatures: tabular,
                        color: pos <= 3 ? Theme.of(context).colorScheme.secondary : null,
                      ),
                    ),
                    _Movement(t),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: Icon(AppIcons.request, color: c.muted),
                tooltip: context.l.request,
                onPressed: t.requestable == false ? null : () => showRequestSheet(context, t),
              ),
            );
          },
        ),
      ]),
    );
  }
}

class _Movement extends StatelessWidget {
  const _Movement(this.t);
  final Track t;
  @override
  Widget build(BuildContext context) {
    if (t.previousPosition == null && t.movement != null) {
      return Text(
        context.l.newEntry,
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF2FB38F)),
      );
    }
    final prev = t.previousPosition, pos = t.position;
    if (prev == null || pos == null || prev == pos) return const SizedBox.shrink();
    final up = pos < prev;
    return Icon(
      up ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
      size: 16,
      color: up ? const Color(0xFF2FB38F) : const Color(0xFFFF5A5F),
    );
  }
}
