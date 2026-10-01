import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/turnstile.dart';
import 'package:seoulfm/ui/icons.dart';

/// Marathon takes votes, not song requests (`MarathonVote`): the artist on air, the queue,
/// open nominations to vote for, and a nominate button. Polls every 10 s while shown.
class MarathonPanel extends StatefulWidget {
  const MarathonPanel({super.key});
  @override
  State<MarathonPanel> createState() => _MarathonPanelState();
}

class _MarathonPanelState extends State<MarathonPanel> {
  MarathonState? _state;
  Timer? _timer;
  bool _failed = false;
  static const _votedKey = 'seoulfm-marathon-voted';

  Set<String> get _voted => (Session.prefs.getStringList(_votedKey) ?? const []).toSet();

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await api.marathon(station: context.read<ChannelController>().active.key);
      if (!mounted) return;
      setState(() {
        _state = s;
        _failed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _vote(MarathonNomination n) async {
    final cta = context.l.marathonVote;
    final result = await showModalBottomSheet<WriteResult>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (_) => _ConfirmWrite(
        title: n.artist.name,
        art: n.artworkUrl,
        action: 'v3_vote',
        cta: cta,
        send: (token) => api.marathonVote(n.id, {'session_id': Session.sessionId, 'value': 1, 'captcha_token': token}),
      ),
    );
    if (result == null || !mounted) return;
    if (result.accepted) {
      await Session.prefs.setStringList(_votedKey, [..._voted, n.id]);
      if (!mounted) return;
    }
    _toast(result.accepted ? context.l.marathonVoted : (result.reason ?? context.l.errorGeneric));
    _load();
  }

  Future<void> _nominate() async {
    final station = context.read<ChannelController>().active.key;
    final pick = await showModalBottomSheet<MarathonCandidate>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const FractionallySizedBox(heightFactor: 0.85, child: _ArtistPicker()),
    );
    if (pick == null || !mounted) return;
    final cta = context.l.marathonNominate;
    final result = await showModalBottomSheet<WriteResult>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (_) => _ConfirmWrite(
        title: pick.artist.name,
        art: pick.artworkUrl,
        action: 'v3_marathon_nominate',
        cta: cta,
        send: (token) => api.marathonNominate({
          'station': station,
          'artist_key': pick.artist.artistKey,
          'session_id': Session.sessionId,
          'idempotency_key': Session.newIdempotencyKey(),
          'captcha_token': token,
        }),
      ),
    );
    if (result == null || !mounted) return;
    _toast(result.reason ?? (result.accepted ? context.l.marathonVoted : context.l.errorGeneric));
    _load();
  }

  void _toast(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final s = _state;
    final c = context.sfm;
    final accent = context.watch<ChannelController>().active.color;
    if (s == null) {
      return _failed
          ? const SizedBox.shrink()
          : const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
    }
    final voted = _voted;
    final open = s.nominations.where((n) => n.status == 'open').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l.marathonOnAir, icon: AppIcons.timer),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(context.l.marathonIntro, style: TextStyle(fontSize: 12, color: c.muted)),
        ),
        if (s.current != null) _BlockCard(block: s.current!, big: true, accent: accent),
        if (s.queue.isNotEmpty) ...[
          SectionHeader(context.l.marathonQueue, icon: AppIcons.request),
          SizedBox(
            height: 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: s.queue.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => SizedBox(
                width: 130,
                child: _BlockCard(block: s.queue[i], accent: accent),
              ),
            ),
          ),
        ],
        SectionHeader(context.l.marathonNominations, icon: AppIcons.vote),
        if (open.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(context.l.marathonEmpty, style: TextStyle(color: c.muted, fontSize: 13)),
          ),
        for (final n in open)
          ListTile(
            leading: Artwork(n.artworkUrl, size: 48),
            title: Text(n.artist.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              context.l.marathonVotes(n.votes, n.votesRequired),
              style: TextStyle(color: c.muted, fontSize: 12),
            ),
            onTap: () => Nav.openArtist(n.artist.artistKey, name: n.artist.name),
            trailing: voted.contains(n.id)
                ? Icon(AppIcons.done, color: accent)
                : FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: readableOn(accent),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: s.accepting ? () => _vote(n) : null,
                    child: Text(context.l.marathonVote),
                  ),
          ),
        if (s.accepting)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
              onPressed: _nominate,
              icon: const Icon(AppIcons.add),
              label: Text(context.l.marathonNominate),
            ),
          ),
      ],
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.block, required this.accent, this.big = false});
  final MarathonBlock block;
  final Color accent;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final start = DateTime.fromMillisecondsSinceEpoch(block.startsAtEpoch * 1000);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(start));
    return GestureDetector(
      onTap: () => Nav.openArtist(block.artist.artistKey, name: block.artist.name),
      child: Container(
        margin: big ? const EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
        height: big ? 180 : 150,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(Radii.lg)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The artist's photo fades in over the cover (`ArtCard`).
            Artwork(block.artworkUrl, radius: 0),
            Artwork('${Config.siteUrl}/api/artist-image/${Uri.encodeComponent(block.artist.artistKey)}/', radius: 0),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (block.source == 'votes')
                    Text(
                      context.l.marathonVotedIn.toUpperCase(),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: accent),
                    ),
                  Text(
                    block.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: big ? 24 : 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  Text(time, style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirm dialog carrying the captcha, for a vote or a nomination.
class _ConfirmWrite extends StatefulWidget {
  const _ConfirmWrite({
    required this.title,
    required this.art,
    required this.action,
    required this.cta,
    required this.send,
  });
  final String title, action, cta;
  final String? art;
  final Future<WriteResult> Function(String? token) send;
  @override
  State<_ConfirmWrite> createState() => _ConfirmWriteState();
}

class _ConfirmWriteState extends State<_ConfirmWrite> {
  String? _token;
  bool _sending = false;

  Future<void> _go() async {
    setState(() => _sending = true);
    try {
      final r = await widget.send(_token);
      if (mounted) Navigator.pop(context, r);
    } on ApiError catch (e) {
      if (mounted) Navigator.pop(context, WriteResult(false, e.message));
    } catch (_) {
      if (mounted) Navigator.pop(context, WriteResult(false, null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ChannelController>().active.color;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Artwork(widget.art, size: 56, radius: Radii.md),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Turnstile(action: widget.action, onToken: (t) => setState(() => _token = t)),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: readableOn(accent),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _sending || (Config.captchaEnabled && _token == null) ? null : _go,
              child: _sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.cta),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistPicker extends StatefulWidget {
  const _ArtistPicker();
  @override
  State<_ArtistPicker> createState() => _ArtistPickerState();
}

class _ArtistPickerState extends State<_ArtistPicker> {
  Timer? _debounce;
  Future<List<MarathonCandidate>> _f = api.marathonArtists('');

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() {
        _f = api.marathonArtists(q.trim());
      }),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: context.l.marathonNominateHint,
              prefixIcon: const Icon(AppIcons.search),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MarathonCandidate>>(
            future: _f,
            builder: (context, s) {
              if (!s.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              return ListView(
                children: [
                  for (final a in s.data!)
                    ListTile(
                      enabled: a.eligible,
                      leading: Artwork(a.artworkUrl, size: 44),
                      title: Text(a.artist.name),
                      subtitle: a.eligible || a.reason == null
                          ? null
                          : Text(a.reason!, style: TextStyle(color: c.faint, fontSize: 12)),
                      onTap: () => Navigator.pop(context, a),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
