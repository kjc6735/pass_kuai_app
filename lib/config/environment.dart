import 'dart:io';

import 'package:flutter/foundation.dart';

class Environment {
  static const apiUrl = String.fromEnvironment('API_URL');
  static const appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const _apiHost = String.fromEnvironment('API_HOST');

  static bool get isProduction => appEnv == 'production';

  static bool get logNetwork => !isProduction && !kReleaseMode;

  static String get baseUrl {
    if (_apiHost.isNotEmpty) return 'http://$_apiHost:3000';
    if (apiUrl.isNotEmpty) return apiUrl;
    if (isProduction) {
      throw StateError('운영 빌드에는 API_URL이 꼭 필요해요.');
    }
    return Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
  }
}
