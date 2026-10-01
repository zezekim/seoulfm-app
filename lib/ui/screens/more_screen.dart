import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/screens/wall_screen.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/language_picker.dart';
import 'package:seoulfm/ui/widgets/support_card.dart';
import 'package:seoulfm/ui/widgets/sleep_timer.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dedications, settings, the car, and about.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _open(String path) =>
      launchUrl(Uri.parse('${Config.siteUrl}$path'), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = context.sfm;
    final l = context.l;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          largeTitleBar(context, l.tabMore),
          SliverList.list(
            children: [
              const SupportCard(),
              ListTile(
                leading: const Icon(AppIcons.dedications),
                title: Text(l.tabWall),
                trailing: Icon(AppIcons.next, color: c.muted),
                onTap: () => Nav.push(const WallScreen()),
              ),
              SectionHeader(l.settings),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PillSegmented<ThemeMode>(
                    options: {
                      ThemeMode.dark: l.themeDark,
                      ThemeMode.light: l.themeLight,
                      ThemeMode.system: l.themeSystem,
                    },
                    selected: app.themeMode,
                    onChanged: app.setTheme,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(AppIcons.language),
                title: Text(l.language),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(languageName(app.locale) ?? l.languageSystem, style: TextStyle(color: c.muted, fontSize: 13)),
                    const SizedBox(width: 4),
                    Icon(AppIcons.next, color: c.muted, size: 18),
                  ],
                ),
                onTap: () => pickLanguage(context),
              ),
              // The time left when a timer runs, nothing (and no repeated label) when not.
              ValueListenableBuilder<DateTime?>(
                valueListenable: app.radio.sleepAt,
                builder: (_, at, _) => ListTile(
                  leading: Icon(at == null ? AppIcons.sleep : AppIcons.sleepOn),
                  title: Text(l.sleepTimer),
                  trailing: at == null
                      ? Icon(AppIcons.next, color: c.muted, size: 18)
                      : Text(
                          l.sleepStopsIn((at.difference(DateTime.now()).inSeconds / 60).ceil()),
                          style: TextStyle(color: c.muted, fontSize: 13),
                        ),
                  onTap: () => pickSleepTimer(context),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: app.radio.losslessActive,
                builder: (_, lossless, _) => ListTile(
                  leading: const Icon(AppIcons.quality),
                  title: Text(l.quality),
                  trailing: Text(lossless ? 'FLAC' : l.qualityAuto, style: TextStyle(color: c.muted)),
                ),
              ),
              SectionHeader(l.inTheCar, icon: AppIcons.car),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.carBody, style: TextStyle(color: c.muted, height: 1.45)),
              ),
              SectionHeader(l.about),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.aboutBody, style: TextStyle(color: c.muted, height: 1.45)),
              ),
              const SizedBox(height: 8),
              ListTile(leading: const Icon(AppIcons.website), title: Text(l.website), onTap: () => _open('/')),
              ListTile(
                leading: const Icon(AppIcons.privacy),
                title: Text(l.privacy),
                onTap: () => _open('/privacy/'),
              ),
              ListTile(
                leading: const Icon(AppIcons.terms),
                title: Text(l.terms),
                onTap: () => _open('/terms/'),
              ),
              ListTile(
                leading: const Icon(AppIcons.mail),
                title: Text(l.contact),
                onTap: () => _open('/contact/'),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.version(Config.appVersion),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.faint, fontSize: 12),
                ),
              ),
            ],
          ),
          // Clear of the floating player and the tab bar.
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom)),
        ],
      ),
    );
  }
}
