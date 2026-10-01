import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:seoulfm/state/session.dart';

/// Listener support through the App Store and Google Play: one-off tips (consumables) and a
/// monthly supporter subscription. Nothing is unlocked by either; supporting changes nothing
/// about how anyone listens (the site's promise).
///
/// The products are created in App Store Connect and the Play Console with these ids; until
/// they exist (or on a device with no store) [available] is false and the page says so.
class SupportStore extends ChangeNotifier {
  static const tips = ['seoulfm.tip.small', 'seoulfm.tip.medium', 'seoulfm.tip.large'];
  static const monthly = 'seoulfm.supporter.monthly';
  static const _supporterKey = 'seoulfm-supporter';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool started = false;

  /// The store answered and has at least one of our products.
  bool available = false;
  Map<String, ProductDetails> products = {};

  /// A purchase in flight (its product id), for the spinner on its button.
  String? pending;

  /// A monthly supporter (from a purchase or a restore). Kept on the device.
  bool supporter = Session.prefs.getBool(_supporterKey) ?? false;

  /// Bumped when a purchase goes through, for the thank-you.
  final ValueNotifier<int> thanked = ValueNotifier(0);

  /// The store's message when a purchase fails (not when the listener cancels).
  String? error;

  Future<void> start() async {
    if (started) return;
    started = true;
    try {
      _sub = _iap.purchaseStream.listen(_onPurchases, onError: (Object _) {});
      if (!await _iap.isAvailable()) return _done();
      final r = await _iap.queryProductDetails({...tips, monthly});
      products = {for (final p in r.productDetails) p.id: p};
      available = products.isNotEmpty;
    } catch (_) {
      available = false;
    }
    _done();
  }

  void _done() => notifyListeners();

  ProductDetails? product(String id) => products[id];

  Future<void> buy(String id) async {
    final p = products[id];
    if (p == null || pending != null) return;
    pending = id;
    error = null;
    notifyListeners();
    final param = PurchaseParam(productDetails: p);
    try {
      final started = id == monthly ? await _iap.buyNonConsumable(purchaseParam: param) : await _iap.buyConsumable(purchaseParam: param);
      if (!started) {
        pending = null;
        notifyListeners();
      }
    } catch (e) {
      pending = null;
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> restore() async {
    try {
      await _iap.restorePurchases();
    } catch (_) {}
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      switch (p.status) {
        case PurchaseStatus.pending:
          pending = p.productID;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (p.productID == monthly) _setSupporter(true);
          if (p.status == PurchaseStatus.purchased) thanked.value++;
          pending = null;
        case PurchaseStatus.error:
          error = p.error?.message;
          pending = null;
        case PurchaseStatus.canceled:
          pending = null;
      }
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
    notifyListeners();
  }

  void _setSupporter(bool on) {
    supporter = on;
    Session.prefs.setBool(_supporterKey, on);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
