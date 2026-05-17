import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/config/app_config.dart';

void main() {
  group('AppConfig.fromEnvironment()', () {
    test('default baseUrl is http://192.168.1.35:5000', () {
      final config = AppConfig.fromEnvironment();
      expect(config.apiBaseUrl, equals('http://192.168.1.35:5000'));
    });
  });
}
