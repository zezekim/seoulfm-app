import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/api.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/platform/request_notifications.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/platform/attestation.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/request_tracker.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/turnstile.dart';
import 'package:seoulfm/ui/icons.dart';

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
  // No captcha when the API waives it for this attested device (docs/app-attestation.md).
  bool _captcha = Config.captchaEnabled && !Attestation.instance.captchaWaived;
  bool _captchaFailed = false;
  int _captchaRun = 0; // a new key loads the captcha fresh
  bool _sending = false;
  RequestSubmission? _result;
  String? _error;
  String? _idempotencyKey;

  bool get _canSend => !_sending && (!_captcha || _token != null);

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
        context.read<RequestTracker>().follow(
          r.requestId!,
          r.statusToken!,
          initial: RequestStatus(r.requestId!, r.status.isEmpty ? 'queued' : r.status, r.track, r.eta, null),
        );
      }
      if (r.accepted) {
        HapticFeedback.heavyImpact();
        // The first accepted request is when a "your song is up" notification makes sense:
        // ask then (once), after the celebration has played.
        Future.delayed(const Duration(milliseconds: 1200), RequestNotifications.askOnce);
      }
      setState(() => _result = r);
    } on ApiError catch (e) {
      if (!mounted) return;
      context.read<AppState>().review.noteError(); // no rating prompt right after this
      setState(() {
        if (e.code == 'captcha_required' && !_captcha) {
          _captcha = true; // the device couldn't prove itself after all: the captcha, then send again
          return;
        }
        _error = e.message;
        _resetCaptcha(); // the token was spent
      });
    } catch (_) {
      if (!mounted) return;
      context.read<AppState>().review.noteError(); // no rating prompt right after this
      setState(() {
        _error = context.l.errorGeneric;
        _resetCaptcha();
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _resetCaptcha() {
    _token = null;
    _captchaFailed = false;
    _captchaRun++;
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
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
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
                      if (_captcha)
                        Turnstile(
                          key: ValueKey(_captchaRun),
                          action: 'v3_request',
                          onToken: (t) => setState(() => _token = t),
                          onError: () => setState(() => _captchaFailed = true),
                        ),
                      if (_captcha && _captchaFailed)
                        TurnstileFailed(onRetry: () => setState(_resetCaptcha))
                      else if (_captcha && _token == null)
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
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: readableOn(accent)),
                              )
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
        if (result.accepted)
          Center(child: _Celebrate(color: accent))
        else
          Icon(AppIcons.info, size: 40, color: c.muted),
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

/// An accepted request: a check springs in and a ring of dots bursts out around it.
class _Celebrate extends StatefulWidget {
  const _Celebrate({required this.color});
  final Color color;
  @override
  State<_Celebrate> createState() => _CelebrateState();
}

class _CelebrateState extends State<_Celebrate> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = readableOn(widget.color);
    return SizedBox(
      width: 120,
      height: 96,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final pop = Curves.elasticOut.transform((_c.value / 0.7).clamp(0.0, 1.0));
          final burst = Curves.easeOutCubic.transform(_c.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 12; i++)
                Transform.translate(
                  offset: Offset.fromDirection(i * 3.14159 / 6, 22 + 30 * burst),
                  child: Opacity(
                    opacity: (1 - burst).clamp(0.0, 1.0),
                    child: Container(
                      width: i.isEven ? 7 : 5,
                      height: i.isEven ? 7 : 5,
                      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                    ),
                  ),
                ),
              Transform.scale(
                scale: pop,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                  child: Icon(AppIcons.check, color: fg, size: 30),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
