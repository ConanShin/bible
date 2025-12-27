import 'dart:io';

class AdService {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Android Test Banner Ad ID
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOS Test Banner Ad ID
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
