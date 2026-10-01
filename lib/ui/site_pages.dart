import 'package:seoulfm/config.dart';
import 'package:seoulfm/data/app_language.dart';
import 'package:url_launcher/url_launcher.dart';

/// The site's language prefixes, by the app's locale keys (English is the unprefixed default).
const _siteLang = {
  'ko': 'kr', 'es': 'mx', 'es_ES': 'es', 'pt': 'pt', 'fr': 'fr', 'de': 'de', 'it': 'it', 'pl': 'pl', //
  'tr': 'tr', 'ru': 'ru', 'kk': 'kz', 'ar': 'ar', 'id': 'id', 'ms': 'my', 'th': 'th', 'vi': 'vn', //
  'ja': 'jp', 'zh': 'cn', 'zh_Hant': 'tw',
};

/// A page of the site ([path] like `/terms/`) in the app's language.
Uri sitePage(String path) {
  final lang = _siteLang[AppLanguage.tag] ?? _siteLang[AppLanguage.language];
  return Uri.parse('${Config.siteUrl}${lang == null ? '' : '/$lang'}$path');
}

/// Opens a site page in a browser window inside the app (Safari View Controller on iOS,
/// a Custom Tab on Android): terms, privacy and contact stay in SeoulFM.
Future<void> openSitePage(String path) async {
  final ok = await launchUrl(sitePage(path), mode: LaunchMode.inAppBrowserView);
  if (!ok) await launchUrl(sitePage(path), mode: LaunchMode.externalApplication);
}

/// The site itself, in the listener's browser.
Future<void> openSite() => launchUrl(sitePage('/'), mode: LaunchMode.externalApplication);
