import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/app/router/route_names.dart';
import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/core/widgets/bl_back_button.dart';
import 'package:better_life_app/core/widgets/bl_mini_logo.dart';
import 'package:better_life_app/core/widgets/bl_primary_button.dart';
import 'package:better_life_app/core/widgets/bl_text_field.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

/// Login screen — FR-002.
///
/// - `ConsumerStatefulWidget` to own TextEditingControllers.
/// - Watches [loginFormProvider] for CTA enable state.
/// - Watches [authNotifierProvider] for loading/error feedback.
/// - "¿Olvidaste tu contraseña?" → SnackBar (not implemented yet).
/// - "Regístrate" → [context.goNamed(RouteNames.register)].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final form = ref.read(loginFormProvider);
    if (!form.canSubmit) return;
    ref.read(authNotifierProvider.notifier).login(
          email: form.email,
          password: form.password,
        );
  }

  void _showDeadLink(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pronto disponible'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Returns null when there is no error to show in the inline error region.
  /// Returns the title string for AuthFailure or a generic fallback.
  String? _inlineError(AuthState auth) {
    if (auth is AuthError) {
      final f = auth.failure;
      if (f is AuthFailure) {
        return f.title.isNotEmpty ? f.title : 'Error de autenticación';
      }
    }
    return null;
  }

  /// Returns per-field errors from a ValidationFailure, if present.
  Map<String, String> _fieldErrors(AuthState auth) {
    if (auth is AuthError && auth.failure is ValidationFailure) {
      final vf = auth.failure as ValidationFailure;
      return vf.errors.map(
        (k, v) => MapEntry(k.toLowerCase(), v.isNotEmpty ? v.first : ''),
      );
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(loginFormProvider);
    final formNotifier = ref.read(loginFormProvider.notifier);
    final auth = ref.watch(authNotifierProvider);

    final isLoading = auth is AuthLoading;
    final inlineError = _inlineError(auth);
    final fieldErrors = _fieldErrors(auth);

    return Scaffold(
      backgroundColor: BLColors.lightBgTop,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            BLSpacing.screenX,
            BLSpacing.screenTop,
            BLSpacing.screenX,
            BLSpacing.screenBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BLBackButton(),
                  BLMiniLogo(key: const Key('login_mini_logo')),
                ],
              ),
              const SizedBox(height: 32),

              // ── Heading ──────────────────────────────────────────────────
              Text(
                'Bienvenido de vuelta',
                style: BLType.h1.copyWith(color: BLColors.lightText),
              ),
              const SizedBox(height: 8),
              Text(
                'Continuemos donde lo dejaste.',
                style: BLType.body.copyWith(color: BLColors.lightTextMuted),
              ),
              const SizedBox(height: 32),

              // ── Form ─────────────────────────────────────────────────────
              BLTextField(
                key: const Key('login_email_field'),
                label: 'Email',
                placeholder: 'tucorreo@ejemplo.com',
                leadingIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                onChanged: formNotifier.setEmail,
                isValid: form.touched.email && form.emailOk,
                errorText: form.touched.email && !form.emailOk
                    ? 'Correo no válido'
                    : fieldErrors['email'],
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
              ),
              const SizedBox(height: BLSpacing.fieldGap),

              BLTextField(
                key: const Key('login_password_field'),
                label: 'Contraseña',
                placeholder: 'Mínimo 8 caracteres',
                leadingIcon: Icons.lock_outline_rounded,
                obscureText: !form.showPassword,
                controller: _passwordController,
                focusNode: _passwordFocus,
                textInputAction: TextInputAction.done,
                onChanged: formNotifier.setPassword,
                onSubmitted: (_) => _submit(),
                trailing: IconButton(
                  key: const Key('login_password_toggle'),
                  icon: Icon(
                    form.showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: BLColors.lightIconFocus,
                  ),
                  onPressed: formNotifier.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 12),

              // ── Forgot password ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _showDeadLink(context),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: BLType.link.copyWith(
                      color: BLColors.lavender400,
                      decoration: TextDecoration.underline,
                      decorationColor: BLColors.lavender400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: BLSpacing.formButtonGap),

              // ── Inline error region ───────────────────────────────────────
              SizedBox(
                height: 18,
                child: inlineError != null
                    ? Text(
                        inlineError,
                        style: BLType.caption.copyWith(
                          fontSize: 12,
                          color: BLColors.danger,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 8),

              // ── CTA ───────────────────────────────────────────────────────
              BLPrimaryButton(
                label: 'Iniciar sesión',
                isLoading: isLoading,
                onPressed: form.canSubmit && !isLoading ? _submit : null,
              ),
              const SizedBox(height: 24),

              // ── Footer ───────────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: BLType.body.copyWith(
                        color: BLColors.lightTextMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed(RouteNames.register),
                      child: Text(
                        'Regístrate',
                        style: BLType.link.copyWith(
                          color: BLColors.lavender500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
