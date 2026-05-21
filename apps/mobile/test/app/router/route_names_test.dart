import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/app/router/route_names.dart';

void main() {
  group('RouteNames', () {
    test('splash name constant', () {
      expect(RouteNames.splash, 'splash');
    });

    test('login name constant', () {
      expect(RouteNames.login, 'login');
    });

    test('register name constant', () {
      expect(RouteNames.register, 'register');
    });

    test('habits name constant', () {
      expect(RouteNames.habits, 'home-habits');
    });

    test('goals name constant', () {
      expect(RouteNames.goals, 'home-goals');
    });

    test('profile name constant', () {
      expect(RouteNames.profile, 'home-profile');
    });
  });

  group('RoutePaths', () {
    test('splash path', () {
      expect(RoutePaths.splash, '/splash');
    });

    test('login path', () {
      expect(RoutePaths.login, '/login');
    });

    test('register path', () {
      expect(RoutePaths.register, '/register');
    });

    test('habits path', () {
      expect(RoutePaths.habits, '/home/habits');
    });

    test('goals path', () {
      expect(RoutePaths.goals, '/home/goals');
    });

    test('profile path', () {
      expect(RoutePaths.profile, '/home/profile');
    });
  });
}
