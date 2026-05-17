sealed class Failure {
  final String title;
  const Failure(this.title);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.title = 'Sin conexión']);
}

final class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;
  const ValidationFailure({required String title, required this.errors})
      : super(title);
}

final class AuthFailure extends Failure {
  final int statusCode;
  const AuthFailure({required String title, required this.statusCode})
      : super(title);
}

final class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure({required String title, required this.statusCode})
      : super(title);
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
