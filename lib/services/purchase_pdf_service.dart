import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchasePdfService {
  static buyPdf(String prefix) async {
    const Set<String> productIds = <String>{'download_comic'};
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      FirebaseAnalytics.instance.logEvent(name: 'error', parameters: {
        'error': 'Product not found',
        'stack_trace': Error().stackTrace.toString(),
        'prefix': prefix
      });
      log('The following ids were not found: ${response.notFoundIDs}');
      return;
    }
    List<ProductDetails> products = response.productDetails;
    for (var product in products) {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    }
  }
}
