import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

const removeAdsProductId = 'remove_ads';

class BillingRepository {
  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  final _premiumController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStream => _premiumController.stream;

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(_handlePurchases);
    await _restorePurchases();
  }

  Future<void> launchPurchaseFlow() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    final response = await _iap.queryProductDetails({removeAdsProductId});
    if (response.productDetails.isEmpty) return;

    final param = PurchaseParam(productDetails: response.productDetails.first);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> _restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _handlePurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == removeAdsProductId &&
          purchase.status == PurchaseStatus.purchased) {
        _isPremium = true;
        _premiumController.add(true);
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _premiumController.close();
  }
}
