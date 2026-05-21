/// Immutable value object that wraps a raw JWT string.
///
/// No Flutter imports — pure Dart domain entity.
class AuthToken {
  final String value;

  const AuthToken({required this.value});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthToken &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AuthToken(value: [REDACTED])';
}
