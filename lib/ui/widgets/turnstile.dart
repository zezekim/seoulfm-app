import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Cloudflare Turnstile in a small web view (`TurnstileWidget`). The page is loaded with
/// seoul.fm as its base URL, so the site key's hostname check passes; the token comes back
/// through a JavaScript channel. Writes need it in production.
class Turnstile extends StatefulWidget {
  const Turnstile({super.key, required this.action, required this.onToken, this.onError});

  /// The captcha action the API expects (`v3_request`, `v3_vote`, `v3_marathon_nominate`).
  final String action;

  /// A fresh token, or null when it expired (the widget then re-challenges by itself).
  final ValueChanged<String?> onToken;

  /// The challenge can't go on: the page or script didn't load, nothing rendered in time,
  /// or Turnstile reported an error. Rebuild with a new key to try again.
  final VoidCallback? onError;

  @override
  State<Turnstile> createState() => _TurnstileState();
}

class _TurnstileState extends State<Turnstile> {
  late final WebViewController _controller;
  Timer? _timeout;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          // iOS leaves isForMainFrame unset; its errors are for the page itself.
          onWebResourceError: (e) {
            if (e.isForMainFrame != false) _fail();
          },
        ),
      )
      ..addJavaScriptChannel(
        'SfmTurnstile',
        onMessageReceived: (m) {
          switch (m.message) {
            case '__ready':
              _timeout?.cancel();
            case '__error':
              _fail();
            case '':
              widget.onToken(null);
            default:
              widget.onToken(m.message);
          }
        },
      );
    // Nothing rendered in time (offline, script blocked): don't leave the user waiting.
    if (Config.captchaEnabled) _timeout = Timer(const Duration(seconds: 15), _fail);
  }

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    // The app's theme, not the phone's: a dark app gets a dark captcha even in light mode.
    final dark = Theme.of(context).brightness == Brightness.dark;
    _controller.loadHtmlString(_html(dark ? 'dark' : 'light'), baseUrl: '${Config.siteUrl}/');
  }

  void _fail() {
    _timeout?.cancel();
    if (_failed || !mounted) return;
    _failed = true;
    widget.onToken(null);
    widget.onError?.call();
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  String _html(String theme) =>
      '''
<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1">
<style>html,body{margin:0;background:transparent;display:flex;justify-content:center}</style>
<script>
function send(t){SfmTurnstile.postMessage(t||'')}
function fail(){send('__error')}
function go(){try{turnstile.render('#w',{sitekey:${jsonEncode(Config.turnstileSiteKey)},action:${jsonEncode(widget.action)},
theme:'$theme',size:'flexible',callback:send,'expired-callback':function(){send('')},'error-callback':fail});send('__ready')}catch(e){fail()}}
</script>
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=go&render=explicit" async defer onerror="fail()"></script></head><body><div id="w" style="width:100%"></div></body></html>''';

  @override
  Widget build(BuildContext context) {
    if (!Config.captchaEnabled) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.md),
      child: SizedBox(height: 70, child: WebViewWidget(controller: _controller)),
    );
  }
}

/// What shows in place of "Verifying…" when the captcha failed: why, and a way to retry.
class TurnstileFailed extends StatelessWidget {
  const TurnstileFailed({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l.verifyFailed,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: context.sfm.muted),
        ),
        TextButton(onPressed: onRetry, child: Text(context.l.retry)),
      ],
    );
  }
}
