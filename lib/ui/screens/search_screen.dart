import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/request_sheet.dart';

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
      setState(() => _results = q.length < 2 ? null : api.search(q, limit: 25));
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
    icon: const Icon(Icons.queue_music_rounded),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Scaffold(
      appBar: AppBar(title: Text(context.l.tabRequest)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _q,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.l.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _q.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _q.clear();
                          _onChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          Expanded(
            child: _results == null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Text(context.l.searchIntro, style: TextStyle(color: c.muted, fontSize: 13)),
                      ),
                      SectionHeader(context.l.newSongs, icon: Icons.fiber_new_rounded),
                      FutureBuilder<List<Track>>(
                        future: _new,
                        builder: (context, s) => s.data == null && !s.hasError
                            ? const SkeletonList()
                            : Column(
                                children: [
                                  for (final t in s.data ?? const <Track>[])
                                    TrackRow(track: t, onTap: () => Nav.openSong(t), trailing: _requestButton(t)),
                                ],
                              ),
                      ),
                    ],
                  )
                : FutureBuilder<SearchResults>(
                    future: _results,
                    builder: (context, s) {
                      if (s.hasError) return ErrorRetry(onRetry: () => _onChanged(_q.text));
                      if (!s.hasData) return const SingleChildScrollView(child: SkeletonList());
                      final r = s.data!;
                      if (r.tracks.isEmpty && r.artists.isEmpty) {
                        return Center(
                          child: Text(context.l.searchEmpty(_q.text.trim()), style: TextStyle(color: c.muted)),
                        );
                      }
                      return ListView(
                        children: [
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
                                  return GestureDetector(
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
                            TrackRow(track: t, onTap: () => Nav.openSong(t), trailing: _requestButton(t)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
