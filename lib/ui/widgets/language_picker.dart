import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// The app's languages, each named in itself (as the site's switcher does).
const appLanguages = <(Locale, String)>[
  (Locale('en'), 'English'),
  (Locale('ko'), '한국어'),
  (Locale('es'), 'Español (Latinoamérica)'),
  (Locale('es', 'ES'), 'Español (España)'),
  (Locale('pt'), 'Português (Brasil)'),
  (Locale('fr'), 'Français'),
  (Locale('de'), 'Deutsch'),
  (Locale('it'), 'Italiano'),
  (Locale('pl'), 'Polski'),
  (Locale('tr'), 'Türkçe'),
  (Locale('ru'), 'Русский'),
  (Locale('kk'), 'Қазақша'),
  (Locale('ar'), 'العربية'),
  (Locale('id'), 'Bahasa Indonesia'),
  (Locale('ms'), 'Bahasa Melayu'),
  (Locale('th'), 'ไทย'),
  (Locale('vi'), 'Tiếng Việt'),
  (Locale('ja'), '日本語'),
  (Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), '简体中文'),
  (Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), '繁體中文'),
];

/// The picked language's own name, or null when following the system.
String? languageName(Locale? l) {
  if (l == null) return null;
  for (final (loc, name) in appLanguages) {
    if (loc == l) return name;
  }
  return null;
}

Future<void> pickLanguage(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (sheet) {
    final app = sheet.read<AppState>();
    final c = sheet.sfm;
    Widget row(Locale? l, String name) {
      final on = app.locale == l;
      return ListTile(
        title: Text(name, style: TextStyle(fontWeight: on ? FontWeight.w700 : FontWeight.w400)),
        trailing: on ? Icon(AppIcons.check, color: Theme.of(sheet).colorScheme.secondary) : null,
        onTap: () {
          app.setLocale(l);
          Navigator.pop(sheet);
        },
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (_, scroll) => ListView(
        controller: scroll,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: c.text.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(9)),
            ),
          ),
          ShelfTitle(sheet.l.language),
          row(null, sheet.l.languageSystem),
          const Divider(),
          for (final (l, name) in appLanguages) row(l, name),
          SizedBox(height: MediaQuery.paddingOf(sheet).bottom + 16),
        ],
      ),
    );
  },
);
