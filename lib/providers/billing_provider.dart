import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BillingProvider extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSub;

  bool _available = false;
  bool _loading = true;
  List<ProductDetails> _products = const [];
  String? _error;

  // Replace with your Play Console product ID for a subscription
  static const String kSubscriptionProductId = 'kindle_clone_monthly';

  BillingProvider() {
    _init();
  }

  bool get isAvailable => _available;
  bool get isLoading => _loading;
  List<ProductDetails> get products => _products;
  String? get error => _error;

  Future<void> _init() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      _loading = false;
      notifyListeners();
      return;
    }

    const ids = <String>{kSubscriptionProductId};
    final response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      _error = response.error!.message;
    } else {
      _products = response.productDetails;
    }

    _purchaseSub = _iap.purchaseStream.listen(_onPurchases);
    _loading = false;
    notifyListeners();
  }

  Future<void> buySubscription() async {
    if (_products.isEmpty) return;
    final product = _products.firstWhere((p) => p.id == kSubscriptionProductId, orElse: () => _products.first);
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        // TODO: validate purchase with backend before granting entitlement
        await _grantSubscription();
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<void> _grantSubscription() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'subscriptionStatus': true},
      SetOptions(merge: true),
    );
  }

  @override
  void dispose() {
    if (_available) {
      _purchaseSub.cancel();
    }
    super.dispose();
  }
}


