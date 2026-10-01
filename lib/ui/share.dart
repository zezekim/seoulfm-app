import 'package:flutter/widgets.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/data/channels.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:share_plus/share_plus.dart';

/// Every share is tagged like the site's (`lib/share.ts`): `utm_source=app`,
/// `utm_medium=share`, `utm_campaign` = the moment.
String shareLink(String url, String campaign) {
  final u = Uri.parse(url);
  return u
      .replace(queryParameters: {...u.queryParameters, 'utm_source': 'app', 'utm_medium': 'share', 'utm_campaign': campaign})
      .toString();
}

/// The song's page: `/song/{id}/` answers 308 to its slug address.
String songUrl(Track t) => '${Config.siteUrl}/song/${Uri.encodeComponent(t.id ?? '')}/';
String artistUrl(String key) => '${Config.siteUrl}/artist/${Uri.encodeComponent(key)}/';

Future<void> shareSong(BuildContext context, Track t) => SharePlus.instance.share(
  ShareParams(text: '${context.l.shareSong(t.displayTitle, t.displayArtist)}\n${shareLink(songUrl(t), 'song')}'),
);

Future<void> shareStation(BuildContext context, Channel c) =>
    SharePlus.instance.share(ShareParams(text: '${context.l.shareStation(c.name)}\n${shareLink(c.webUrl, 'station')}'));
