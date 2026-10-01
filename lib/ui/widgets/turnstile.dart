import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Cloudflare Turnstile in a small web view (`TurnstileWidget`). The page is loaded with
/// seoul.fm as its base URL, so the site key's hostname check passes; the token comes back
/// through a JavaScript channel. Writes need it in production.
class Turnstile extends StatefulWidget {
  const Turnstile({super.key, required this.action, required this.onToken});

  /// The captcha action the API expects (`v3_request`, `v3_vote`, `v3_marathon_nominate`).
  final String action;

  /// A fresh token, or null when it expired or failed.
  final ValueChanged<String?> onToken;

  @override
  State<Turnstile> createState() => _TurnstileState();
}

class _TurnstileState extends State<Turnstile> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final dark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'SfmTurnstile',
        onMessageReceived: (m) {
          widget.onToken(m.message.isEmpty ? null : m.message);
        },
      )
      ..loadHtmlString(_html(dark ? 'dark' : 'light'), baseUrl: '${Config.siteUrl}/');
  }

  String _html(String theme) =>
      '''
<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1">
<style>html,body{margin:0;background:transparent;display:flex;justify-content:center}</style>
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=go&render=explicit" async defer></script>
<script>
function send(t){SfmTurnstile.postMessage(t||'')}
function go(){turnstile.render('#w',{sitekey:${jsonEncode(Config.turnstileSiteKey)},action:${jsonEncode(widget.action)},
theme:'$theme',size:'flexible',callback:send,'expired-callback':function(){send('')},'error-callback':function(){send('')}})}
</script></head><body><div id="w" style="width:100%"></div></body></html>''';

  @override
  Widget build(BuildContext context) {
    if (!Config.captchaEnabled) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.md),
      child: SizedBox(height: 70, child: WebViewWidget(controller: _controller)),
    );
  }
}
