import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/app/router/route_names.dart';
import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/core/widgets/bl_back_button.dart';
import 'package:better_life_app/core/widgets/bl_mini_logo.dart';
import 'package:better_life_app/core/widgets/bl_primary_button.dart';
import 'package:better_life_app/core/widgets/bl_strength_meter.dart';
import 'package:better_life_app/core/widgets/bl_text_field.dart';
import 'package:better_life_app/features/auth/domain/validators.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

/// Sign Up screen — FR-003.
///
/// - `ConsumerStatefulWidget` to own TextEditingControllers.
/// - Watches [signUpFormProvider] for form state and CTA enable logic.
/// - Watches [authNotifierProvider] for loading / error feedback.
/// - "Términos" and "Política de privacidad" → SnackBar "Pronto disponible".
/// - "Inicia sesión" → [context.goNamed(RouteNames.login)].
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final form = ref.read(signUpFormProvider);
    if (!form.canSubmit) return;
    ref.read(authNotifierProvider.notifier).register(
          name: form.name,
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

  /// Returns inline error text for AuthFailure variants.
  String? _inlineError(AuthState auth) {
    if (auth is AuthError) {
      final f = auth.failure;
      if (f is AuthFailure) {
        return f.title.isNotEmpty ? f.title : 'Error al crear la cuenta';
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
    final form = ref.watch(signUpFormProvider);
    final formNotifier = ref.read(signUpFormProvider.notifier);
    final auth = ref.watch(authNotifierProvider);

    final isLoading = auth is AuthLoading;
    final inlineError = _inlineError(auth);
    final fieldErrors = _fieldErrors(auth);
    final strength = strengthOf(form.password);
    final showStrengthMeter = form.password.isNotEmpty;

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
                  BLMiniLogo(key: const Key('signup_mini_logo')),
                ],
              ),
              const SizedBox(height: 32),

              // ── Heading ──────────────────────────────────────────────────
              Text(
                'Crea tu cuenta',
                style: BLType.h1.copyWith(color: BLColors.lightText),
              ),
              const SizedBox(height: 8),
              Text(
                'Empieza tu camino hacia mejores hábitos.',
                style: BLType.body.copyWith(color: BLColors.lightTextMuted),
              ),
              const SizedBox(height: 32),

              // ── Form ─────────────────────────────────────────────────────
              BLTextField(
                key: const Key('signup_name_field'),
                label: 'Nombre',
                placeholder: 'Tu nombre',
                leadingIcon: Icons.person_outline_rounded,
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onChanged: formNotifier.setName,
                isValid: form.touched.name && form.nameOk,
                errorText: form.touched.name && !form.nameOk
                    ? 'Demasiado corto'
                    : fieldErrors['name'],
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocus),
              ),
              const SizedBox(height: BLSpacing.fieldGap),

              BLTextField(
                key: const Key('signup_email_field'),
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
                key: const Key('signup_password_field'),
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
                  key: const Key('signup_password_toggle'),
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

              // ── Strength meter (visible only when password is non-empty) ──
              if (showStrengthMeter) ...[
                const SizedBox(height: 10),
                BLStrengthMeter(strength: strength),
              ],
              const SizedBox(height: BLSpacing.fieldGap),

              // ── Terms caption ─────────────────────────────────────────────
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'Al continuar, aceptas nuestros ',
                      style: BLType.caption.copyWith(
                        color: BLColors.lightTextMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showDeadLink(context),
                      child: Text(
                        'Términos',
                        style: BLType.caption.copyWith(
                          color: BLColors.lavender500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      ' y ',
                      style: BLType.caption.copyWith(
                        color: BLColors.lightTextMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showDeadLink(context),
                      child: Text(
                        'Política de privacidad',
                        style: BLType.caption.copyWith(
                          color: BLColors.lavender500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '.',
                      style: BLType.caption.copyWith(
                        color: BLColors.lightTextMuted,
                      ),
                    ),
                  ],
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
                label: 'Crear cuenta',
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
                      '¿Ya tienes cuenta? ',
                      style: BLType.body.copyWith(
                        color: BLColors.lightTextMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed(RouteNames.login),
                      child: Text(
                        'Inicia sesión',
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
