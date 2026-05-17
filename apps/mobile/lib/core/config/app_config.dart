import 'package:flutter/foundation.dart';

class AppConfig {
  final String apiBaseUrl;

  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://192.168.1.35:5000',
    );
    if (kDebugMode &&
        const String.fromEnvironment('API_BASE_URL').isEmpty) {
      debugPrint(
        '[AppConfig] API_BASE_URL not set via --dart-define. '
        'Using dev default: $baseUrl',
      );
    }
    return const AppConfig(apiBaseUrl: baseUrl);
  }
}
