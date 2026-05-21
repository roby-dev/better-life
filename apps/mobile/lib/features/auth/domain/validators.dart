// Pure domain validators. No Flutter imports — fully unit-testable.

// ---------------------------------------------------------------------------
// Name
// ---------------------------------------------------------------------------

/// Returns an error message if [value] is too short, otherwise `null`.
///
/// Rule: trimmed length must be >= 2.
String? nameValidator(String? value) {
  final s = (value ?? '').trim();
  if (s.length < 2) return 'Demasiado corto';
  return null;
}

// ---------------------------------------------------------------------------
// Email
// ---------------------------------------------------------------------------

final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Returns an error message for an invalid email, otherwise `null`.
String? emailValidator(String? value) {
  if (value == null || !_emailRe.hasMatch(value)) return 'Correo no válido';
  return null;
}

// ---------------------------------------------------------------------------
// Password strength
// ---------------------------------------------------------------------------

/// Scores a password from 0 to 4.
///
/// Scoring:
/// - `length >= 8` → +1
/// - Contains uppercase letter → +1
/// - Contains digit → +1
/// - Contains special character → +1
/// - `length >= 12` → +1 (bonus; result capped at 4)
int strengthOf(String pw) {
  var score = 0;
  if (pw.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(pw)) score++;
  if (RegExp(r'[0-9]').hasMatch(pw)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) score++;
  if (pw.length >= 12) score++;
  return score > 4 ? 4 : score;
}

/// Human-readable labels indexed by [strengthOf] score (0–4).
const strengthLabels = ['', 'Débil', 'Aceptable', 'Buena', 'Excelente'];
