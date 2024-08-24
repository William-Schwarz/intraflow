import 'package:flutter/foundation.dart';

class AppConfig {
  bool sendNotification = kDebugMode ? false : true;
  double? widhtWebPage = kIsWeb ? 700 : null;
  num? widhtMediaQueryWebPageLogin = kIsWeb ? 0.4 : 1;
  num? widhtMediaQueryWebPage = kIsWeb ? 0.7 : 1;
}
