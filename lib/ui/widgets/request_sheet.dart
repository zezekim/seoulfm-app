import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/request_tracker.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/turnstile.dart';

/// Request a song on the tuned station (`useSongRequest`): availability, an optional
/// dedication, the captcha, then the API's answer shown as it is.
Future<void> showRequestSheet(BuildContext context, Track track) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useRootNavigator: true,
  builder: (sheet) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
    child: _RequestSheet(track: track),
  ),
);

class _RequestSheet extends StatefulWidget {
  const _RequestSheet({required this.track});
  final Track track;
  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  final _name = TextEditingController(text: Session.prefs.getString('seoulfm-request-name') ?? '');
  final _message = TextEditingController();
  late final Future<TrackAvailability> _availability = api.requestEta(widget.track.id ?? '');
  String? _token;
  bool _sending = false;
  RequestSubmission? _result;
  String? _error;
  String? _idempotencyKey;

  bool get _canSend => !_sending && (!Config.captchaEnabled || _token != null);

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    _idempotencyKey ??= Session.newIdempotencyKey();
    final name = _name.text.trim();
    if (name.isNotEmpty) Session.prefs.setString('seoulfm-request-name', name);
    try {
      final r = await api.submitRequest({
        'track_id': widget.track.id,
        'station': context.read<ChannelController>().active.key,
        'name': name.isEmpty ? null : name,
        'message': _message.text.trim().isEmpty ? null : _message.text.trim(),
        'session_id': Session.sessionId,
        'idempotency_key': _idempotencyKey,
        'captcha_token': _token,
      });
      if (!mounted) return;
      if (r.accepted && r.requestId != null && r.statusToken != null) {
        context.read<RequestTracker>().follow(r.requestId!, r.statusToken!);
      }
      setState(() => _result = r);
    } on ApiError catch (e) {
      setState(() {
        _error = e.message;
        _token = null;
      });
    } catch (_) {
      setState(() {
        _error = context.l.errorGeneric;
        _token = null;
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String? _eta(RequestEta eta) {
    if (eta.etaMinutes == null) return null;
    return eta.etaMinutes! <= 1 ? context.l.etaSoon : context.l.etaMinutes(eta.etaMinutes!);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final accent = context.watch<ChannelController>().active.color;
    final t = widget.track;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Artwork(t.artworkUrl, size: 64, radius: Radii.md),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l.requestTitle.toUpperCase(), style: eyebrow(context)),
                      const SizedBox(height: 4),
                      Text(
                        t.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        t.displayArtist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_result != null)
              _ResultView(result: _result!, eta: _eta(_result!.eta), accent: accent)
            else
              FutureBuilder<TrackAvailability>(
                future: _availability,
                builder: (context, s) {
                  final a = s.data;
                  if (a != null && !a.requestable) {
                    return Text(a.reason ?? context.l.notRequestable, style: TextStyle(color: c.muted));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _name,
                        maxLength: 40,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(hintText: context.l.yourName, counterText: ''),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _message,
                        maxLength: 200,
                        maxLines: 3,
                        minLines: 2,
                        decoration: InputDecoration(hintText: context.l.dedication),
                      ),
                      const SizedBox(height: 8),
                      Turnstile(action: 'v3_request', onToken: (t) => setState(() => _token = t)),
                      if (Config.captchaEnabled && _token == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            context.l.verifying,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: c.faint),
                          ),
                        ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_error!, style: const TextStyle(color: Color(0xFFFF6B6B))),
                        ),
                      const SizedBox(height: 14),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: readableOn(accent),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _canSend ? _send : null,
                        child: _sending
                            ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: readableOn(accent)))
                            : Text(context.l.sendRequest),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.eta, required this.accent});
  final RequestSubmission result;
  final String? eta;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          result.accepted ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 40,
          color: result.accepted ? accent : c.muted,
        ),
        const SizedBox(height: 10),
        Text(
          result.accepted ? context.l.requestAccepted : '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        // The API's reason, as it is.
        if (result.reason.isNotEmpty)
          Text(
            result.reason,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, height: 1.4),
          ),
        if (result.accepted && eta != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              eta!,
              textAlign: TextAlign.center,
              style: TextStyle(color: accent, fontWeight: FontWeight.w600),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(context.l.close)),
      ],
    );
  }
}
