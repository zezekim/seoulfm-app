import 'package:flutter/foundation.dart';
import 'package:seoulfm/api/models.dart';
import 'package:seoulfm/state/session.dart';

/// Dedications are listeners' own words, shown to everyone, so any of them can be reported
/// and a listener can hide everyone else's by name (App Store guideline 1.2). Both are kept on
/// the device; a report also reaches the team (`reportDedication`).
class Moderation extends ChangeNotifier {
  static const _namesKey = 'seoulfm-hidden-names';
  static const _entriesKey = 'seoulfm-hidden-entries';
  static const _maxEntries = 200;

  final Set<String> _names = {...?Session.prefs.getStringList(_namesKey)};
  final List<String> _entries = [...?Session.prefs.getStringList(_entriesKey)];

  bool get hidesAny => _names.isNotEmpty || _entries.isNotEmpty;

  static String _norm(String name) => name.trim().toLowerCase();

  /// Whether [d] (from entry [entryId], when known) should be left out.
  bool hides(Dedication? d, {String? entryId}) {
    if (d == null) return false;
    if (entryId != null && entryId.isNotEmpty && _entries.contains(entryId)) return true;
    return d.name != null && _names.contains(_norm(d.name!));
  }

  void hideName(String name) {
    if (!_names.add(_norm(name))) return;
    Session.prefs.setStringList(_namesKey, _names.toList());
    notifyListeners();
  }

  /// Hides one reported dedication.
  void hideEntry(String entryId) {
    if (entryId.isEmpty || _entries.contains(entryId)) return;
    _entries.add(entryId);
    if (_entries.length > _maxEntries) _entries.removeRange(0, _entries.length - _maxEntries);
    Session.prefs.setStringList(_entriesKey, _entries);
    notifyListeners();
  }

  void showAll() {
    _names.clear();
    _entries.clear();
    Session.prefs
      ..remove(_namesKey)
      ..remove(_entriesKey);
    notifyListeners();
  }
}
