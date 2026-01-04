import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../providers/user_provider.dart';

class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final Logger _logger = Logger();
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  UserProvider? _userProvider;

  static const String productIdRemoveAds = 'remove_ads_product';

  void initialize(UserProvider userProvider) {
    _userProvider = userProvider;
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        _logger.e('IAP Error: $error');
      },
    );

    // Attempt to restore purchases on startup quietly
    restorePurchases();
  }

  Future<bool> isSimulator() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return !iosInfo.isPhysicalDevice;
      }
    } catch (e) {
      _logger.w('Device info plugin not ready: $e');
    }
    return false;
  }

  Future<void> buyRemoveAds() async {
    if (await isSimulator()) {
      _logger.i('Running on simulator, simulating success');
      await simulateSuccess();
      return;
    }

    final bool available = await _iap.isAvailable();
    if (!available) {
      _logger.e('Store not available');
      return;
    }

    const Set<String> kIds = <String>{productIdRemoveAds};
    final ProductDetailsResponse response = await _iap.queryProductDetails(
      kIds,
    );

    if (response.notFoundIDs.isNotEmpty) {
      _logger.e('Product not found: ${response.notFoundIDs.first}');
      // Fallback for debug/test if product not in store yet
      if (Platform.isIOS || Platform.isAndroid) {
        _logger.i('Fallback to simulation in non-prod environment');
        await simulateSuccess();
      }
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    try {
      if (await isSimulator()) return;

      final bool available = await _iap.isAvailable();
      if (!available) return;

      await _iap.restorePurchases();
    } catch (e) {
      _logger.e('Error restoring purchases: $e');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _logger.e('Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _logger.i('Purchase successful/restored: ${purchaseDetails.status}');
          await _userProvider?.setAdFree(true);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  // For testing/simulators: simulate successful purchase
  Future<void> simulateSuccess() async {
    await _userProvider?.setAdFree(true);
  }
}
