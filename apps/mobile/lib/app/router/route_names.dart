/// Route name and path constants for the BetterLife app router.
///
/// Use [RouteNames] with [GoRouter.goNamed] / [GoRouter.pushNamed].
/// Use [RoutePaths] for imperative navigation with [GoRouter.go].
abstract class RouteNames {
  static const splash    = 'splash';
  static const login     = 'login';
  static const register  = 'register';
  static const dashboard = 'dashboard';
  static const habits    = 'home-habits';
  static const goals     = 'home-goals';
  static const profile   = 'home-profile';
  static const habitForm = 'habit-form';
}

abstract class RoutePaths {
  static const splash    = '/splash';
  static const login     = '/login';
  static const register  = '/register';
  static const dashboard = '/dashboard';
  static const habits    = '/home/habits';
  static const goals     = '/home/goals';
  static const profile   = '/home/profile';
  static const habitForm = '/home/habits/form';
}
