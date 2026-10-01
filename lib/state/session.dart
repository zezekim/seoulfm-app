import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Identity shared by heartbeats, requests, votes and ratings (lib/session.ts):
/// a random session id per app launch, and an anonymous listener id kept on the device.
class Session {
  Session._();
  static late final SharedPreferences prefs;
  static final String sessionId = _hex32();
  static late final String listenerId;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('sfm_listener_id');
    if (id == null || !RegExp(r'^[A-Za-z0-9_-]{8,128}$').hasMatch(id)) {
      id = _hex32();
      await prefs.setString('sfm_listener_id', id);
    }
    listenerId = id;
  }

  static String newIdempotencyKey() => const Uuid().v4();

  static String _hex32() {
    final r = Random.secure();
    return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}
