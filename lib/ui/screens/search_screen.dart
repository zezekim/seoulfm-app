import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';
import 'package:seoulfm/ui/icons.dart';

/// Search the library (songs and artists) on the tuned station, and request from it.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController();
  Timer? _debounce;
  Future<SearchResults>? _results;
  late final Future<List<Track>> _new = api.newTracks(limit: 30);

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = v.trim();
      final results = q.length < 2 ? null : api.search(q, limit: 25);
      setState(() {
        _results = results;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  Widget _requestButton(Track t) => IconButton(
    tooltip: context.l.request,
    onPressed: t.requestable == false ? null : () => showRequestSheet(context, t),
    icon: const Icon(AppIcons.request),
  );

  /// A results list under the collapsing header (the injector keeps it clear of the pinned bar).
  Widget _list(BuildContext context, List<Widget> children) => CustomScrollView(
    slivers: [
      SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
      SliverList.list(children: children),
      // Clear of the floating player and the tab bar.
      SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 16)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final field = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: TextField(
        controller: _q,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.l.searchHint,
          prefixIcon: const Icon(AppIcons.search),
          suffixIcon: _q.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _q.clear();
                    _onChanged('');
                  },
                  icon: const Icon(AppIcons.close),
                ),
        ),
      ),
    );
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: largeTitleBar(
              context,
              context.l.tabRequest,
              bottom: PreferredSize(preferredSize: const Size.fromHeight(60), child: field),
            ),
          ),
        ],
        body: Builder(
          builder: (context) => _results == null
              ? _list(context, [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                    child: Text(context.l.searchIntro, style: TextStyle(color: c.muted, fontSize: 13)),
                  ),
                  SectionHeader(context.l.newSongs, icon: AppIcons.fresh),
                  FutureBuilder<List<Track>>(
                    future: _new,
                    builder: (context, s) => s.data == null && !s.hasError
                        ? const SkeletonList()
                        : Column(
                            children: [
                              for (final t in s.data ?? const <Track>[])
                                TrackRow(requestable: true, track: t, onTap: () => Nav.openSong(t), trailing: _requestButton(t)),
                            ],
                          ),
                  ),
                ])
              : FutureBuilder<SearchResults>(
                  future: _results,
                  builder: (context, s) {
                    if (s.hasError) return _list(context, [ErrorRetry(error: s.error, onRetry: () => _onChanged(_q.text))]);
                    if (!s.hasData) return _list(context, const [SkeletonList()]);
                    final r = s.data!;
                    if (r.tracks.isEmpty && r.artists.isEmpty) {
                      return _list(context, [
                        EmptyState(
                          icon: AppIcons.searchEmpty,
                          title: context.l.searchEmpty(_q.text.trim()),
                          body: context.l.noResultsBody,
                        ),
                      ]);
                    }
                    return _list(context, [
                      if (r.artists.isNotEmpty) ...[
                        SectionHeader(context.l.artists),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: r.artists.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (_, i) {
                              final a = r.artists[i];
                              return Pressable(
                                onTap: () => Nav.openArtist(a.key, name: a.name),
                                child: SizedBox(
                                  width: 84,
                                  child: Column(
                                    children: [
                                      Artwork(a.artworkUrl, size: 84, radius: 42),
                                      const SizedBox(height: 6),
                                      Text(
                                        a.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (r.tracks.isNotEmpty) SectionHeader(context.l.songs),
                      for (final t in r.tracks)
                        TrackRow(requestable: true, track: t, onTap: () => Nav.openSong(t), trailing: _requestButton(t)),
                    ]);
                  },
                ),
        ),
      ),
    );
  }
}
