import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:seoulfm/state/session.dart';

/// What a restore found, for the page's snack bar.
enum RestoreResult { restored, nothing, failed }

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

  /// Asking the store for the products; the page shows a spinner meanwhile.
  bool loading = false;

  /// The store answered and has at least one of our products.
  bool available = false;
  Map<String, ProductDetails> products = {};

  /// A purchase in flight (its product id), for the spinner on its button.
  String? pending;

  /// A monthly supporter (from a purchase or a restore). Kept on the device.
  bool supporter = Session.prefs.getBool(_supporterKey) ?? false;

  /// Bumped when a purchase goes through, for the thank-you.
  final ValueNotifier<int> thanked = ValueNotifier(0);

  /// A purchase failed (not when the listener cancels); the page says so.
  bool failed = false;

  /// The store's own words for the failure, when it gave readable ones.
  String? storeMessage;

  /// Completed by the first restored purchase while [restore] waits.
  Completer<void>? _restoring;

  /// Listens for transactions from launch, not only once Support is open: a purchase can
  /// finish later (Ask to Buy, a pending payment), and Google refunds one that isn't
  /// acknowledged within three days.
  void listen() {
    try {
      _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: _onStreamError);
    } catch (_) {}
  }

  /// Asks the store for the products. Runs again after a failure or an empty answer (offline,
  /// products not approved yet), so reopening the page or Retry can bring them back.
  Future<void> start() async {
    if (loading || available) return;
    loading = true;
    notifyListeners();
    try {
      listen();
      if (await _iap.isAvailable()) {
        final r = await _iap.queryProductDetails({...tips, monthly});
        products = {for (final p in r.productDetails) p.id: p};
        available = products.isNotEmpty;
      }
    } catch (_) {
      available = false;
    }
    loading = false;
    notifyListeners();
  }

  void _fail([String? message]) {
    failed = true;
    // Both plugins put codes here ("SKErrorDomain", "BillingResponse.error", or nothing);
    // only a sentence is worth showing as is.
    storeMessage = message != null && message.trim().contains(' ') ? message.trim() : null;
  }

  void _onStreamError(Object _) {
    pending = null;
    _fail();
    notifyListeners();
  }

  ProductDetails? product(String id) => products[id];

  Future<void> buy(String id) async {
    final p = products[id];
    if (p == null || pending != null) return;
    pending = id;
    failed = false;
    storeMessage = null;
    notifyListeners();
    final param = PurchaseParam(productDetails: p);
    try {
      final started = id == monthly ? await _iap.buyNonConsumable(purchaseParam: param) : await _iap.buyConsumable(purchaseParam: param);
      if (!started) {
        pending = null;
        notifyListeners();
      }
    } catch (_) {
      // A PlatformException (a pending transaction, a store error): its text is for developers.
      pending = null;
      _fail();
      notifyListeners();
    }
  }

  /// Restored purchases arrive on the purchase stream, around when restorePurchases returns
  /// (and with nothing at all when there are none), so wait a moment for the first one.
  Future<RestoreResult> restore() async {
    final found = _restoring = Completer<void>();
    try {
      await _iap.restorePurchases();
      await found.future.timeout(const Duration(seconds: 3));
      return RestoreResult.restored;
    } on TimeoutException {
      return RestoreResult.nothing;
    } catch (_) {
      return found.isCompleted ? RestoreResult.restored : RestoreResult.failed;
    } finally {
      _restoring = null;
    }
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
          final r = _restoring;
          if (p.status == PurchaseStatus.restored && r != null && !r.isCompleted) r.complete();
          pending = null;
        case PurchaseStatus.error:
          _fail(p.error?.message);
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
