import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/state/moderation.dart';
import 'package:seoulfm/state/session.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/site_pages.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:url_launcher/url_launcher.dart';

/// Report a dedication, or hide everything from its sender: the sheet behind a dedication's ⋯.
Future<void> showDedicationActions(BuildContext context, {required Dedication dedication, required Track track, String? entryId}) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (sheet) {
        final name = dedication.name;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(AppIcons.report),
                title: Text(sheet.l.reportDedication),
                onTap: () {
                  Navigator.pop(sheet);
                  reportDedication(context, dedication: dedication, track: track, entryId: entryId);
                },
              ),
              if (name != null)
                ListTile(
                  leading: const Icon(AppIcons.hide),
                  title: Text(sheet.l.hideDedicationsFrom(name)),
                  onTap: () {
                    Navigator.pop(sheet);
                    context.read<Moderation>().hideName(name);
                  },
                ),
            ],
          ),
        );
      },
    );

/// Sends the team a report by email (prefilled with what they need to find it), falling back to
/// the contact page without a mail app, and hides the dedication here at once.
Future<void> reportDedication(BuildContext context, {required Dedication dedication, required Track track, String? entryId}) async {
  final moderation = context.read<Moderation>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final thanks = context.l.reportThanks;
  final body = [
    'Reported dedication',
    if (entryId != null && entryId.isNotEmpty) 'Entry: $entryId',
    'Song: ${track.displayTitle} — ${track.displayArtist}${track.id == null ? '' : ' (${track.id})'}',
    if (dedication.name != null) 'From: ${dedication.name}',
    if (dedication.message != null) 'Message: ${dedication.message}',
    'Listener: ${Session.listenerId}',
    '',
    'Why (optional):',
  ].join('\n');
  final mail = Uri(
    scheme: 'mailto',
    path: Config.reportEmail,
    query: 'subject=${Uri.encodeComponent('Report: dedication')}&body=${Uri.encodeComponent(body)}',
  );
  var sent = false;
  try {
    sent = await launchUrl(mail, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!sent) await openSitePage('/contact/');
  if (entryId != null && entryId.isNotEmpty) {
    moderation.hideEntry(entryId);
  } else if (dedication.name != null) {
    moderation.hideName(dedication.name!);
  }
  messenger?.showSnackBar(SnackBar(content: Text(thanks)));
}
