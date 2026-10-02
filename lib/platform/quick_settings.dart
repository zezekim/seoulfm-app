import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android Quick Settings tile (`RadioTileService.kt`): play and pause from the shade.
/// Android 13 and later can ask the system to add it; earlier, the listener edits the panel.
class QuickSettingsTile {
  QuickSettingsTile._();

  static const _channel = MethodChannel('fm.seoul/tile');

  /// Whether the app can offer to add the tile (asked once).
  static final Future<bool> canAdd = () async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _channel.invokeMethod<bool>('canAdd') ?? false;
    } catch (_) {
      return false;
    }
  }();

  /// Shows the system's prompt; true when the tile is in the panel afterwards (added now or before).
  static Future<bool> add() async {
    try {
      final code = await _channel.invokeMethod<int>('add');
      // StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ALREADY_ADDED (1) and _TILE_ADDED (2).
      return code == 1 || code == 2;
    } catch (_) {
      return false;
    }
  }
}
