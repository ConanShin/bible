import 'dart:io';

class AdService {
  static String? getBannerAdUnitId(bool isAdFree) {
    if (isAdFree) return null;

    if (Platform.isAndroid) {
      // Android Production Banner Ad ID
      return 'ca-app-pub-4102110744790841/1875374700';
    } else if (Platform.isIOS) {
      // iOS Test Banner Ad ID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return null;
  }
}
