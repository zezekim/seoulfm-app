import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:seoulfm/ui/widgets/sleep_timer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings, the car, and about.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _open(String path) => launchUrl(Uri.parse('${Config.siteUrl}$path'), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = context.sfm;
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.tabMore)),
      body: ListView(
        children: [
          SectionHeader(l.settings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark), icon: const Icon(Icons.dark_mode_outlined)),
                ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight), icon: const Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem), icon: const Icon(Icons.brightness_auto_outlined)),
              ],
              selected: {app.themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (s) => app.setTheme(s.first),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.bedtime_outlined),
            title: Text(l.sleepTimer),
            trailing: const SleepTimerButton(),
            onTap: () => pickSleepTimer(context),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: app.radio.losslessActive,
            builder: (_, lossless, _) => ListTile(
              leading: const Icon(Icons.graphic_eq_rounded),
              title: Text(l.quality),
              trailing: Text(lossless ? 'FLAC' : l.qualityAuto, style: TextStyle(color: c.muted)),
            ),
          ),
          SectionHeader(l.inTheCar, icon: Icons.directions_car_outlined),
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
          ListTile(leading: const Icon(Icons.public_rounded), title: Text(l.website), onTap: () => _open('/')),
          ListTile(leading: const Icon(Icons.shield_outlined), title: Text(l.privacy), onTap: () => _open('/privacy/')),
          ListTile(leading: const Icon(Icons.description_outlined), title: Text(l.terms), onTap: () => _open('/terms/')),
          ListTile(leading: const Icon(Icons.mail_outline_rounded), title: Text(l.contact), onTap: () => _open('/contact/')),
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
    );
  }
}
