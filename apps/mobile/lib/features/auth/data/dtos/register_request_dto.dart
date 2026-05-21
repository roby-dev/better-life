/// DTO for POST /api/auth/register.
///
/// Pure Dart — no Flutter imports. No codegen.
class RegisterRequestDto {
  final String name;
  final String email;
  final String password;
  final String timeZone;

  const RegisterRequestDto({
    required this.name,
    required this.email,
    required this.password,
    required this.timeZone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'timeZone': timeZone,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterRequestDto &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          password == other.password &&
          timeZone == other.timeZone;

  @override
  int get hashCode => Object.hash(name, email, password, timeZone);
}
