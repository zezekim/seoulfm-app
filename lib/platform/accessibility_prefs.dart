import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The display settings Flutter doesn't report. iOS's Reduce Transparency comes from the app
/// delegate (`fm.seoul/a11y`), read once at launch and pushed on every change; Android has no
/// such setting. Increase Contrast and Reduce Motion come through [MediaQuery] (see [A11yX]).
class AccessibilityPrefs {
  AccessibilityPrefs._();

  static const _channel = MethodChannel('fm.seoul/a11y');

  /// iOS Settings › Accessibility › Display & Text Size › Reduce Transparency.
  static final ValueNotifier<bool> reduceTransparency = ValueNotifier(false);

  static Future<void> start() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'reduceTransparency') reduceTransparency.value = call.arguments == true;
      return null;
    });
    try {
      reduceTransparency.value = await _channel.invokeMethod<bool>('reduceTransparency') ?? false;
    } catch (_) {
      // An older native build without the channel: keep the glass.
    }
  }
}

/// Puts [AccessibilityPrefs.reduceTransparency] in the tree, so what reads it rebuilds when it
/// changes. Always the same single widget, whatever the value.
class AccessibilityScope extends InheritedNotifier<ValueNotifier<bool>> {
  AccessibilityScope({super.key, required super.child}) : super(notifier: AccessibilityPrefs.reduceTransparency);
}

extension A11yX on BuildContext {
  /// Whether to draw glass as a solid pane: Reduce Transparency (iOS) or a high-contrast
  /// setting (iOS Increase Contrast, Android high-contrast text).
  bool get solidGlass {
    final scope = dependOnInheritedWidgetOfExactType<AccessibilityScope>();
    return (scope?.notifier ?? AccessibilityPrefs.reduceTransparency).value || MediaQuery.highContrastOf(this);
  }

  bool get highContrast => MediaQuery.highContrastOf(this);

  /// iOS Reduce Motion, Android "Remove animations".
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}
