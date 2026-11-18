import 'dart:io';

class Environment {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.dev.com',
  );
  static const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'dev_key',
  );
  static const appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => appEnv == 'production';

  static const _apiHost = String.fromEnvironment('API_HOST');

  static String get baseUrl {
    if (_apiHost.isNotEmpty) {
      return 'http://$_apiHost:3000';
    }
    return Platform.isIOS
        ? 'http://gimjaechan-ui-MacBookPro.local:3000'
        : 'http://localhost:3000';
  }
}
