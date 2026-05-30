import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/editorial_heading.dart';
import '../../core/widgets/password_reveal_toggle.dart';
import '../../providers/session_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(sessionProvider.notifier).signIn(
          email: _emailCtl.text.trim(),
          password: _passwordCtl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SessionState>(sessionProvider, (previous, next) {
      final error = next.error;
      if (error != null && error != previous?.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    });

    final isLoading = ref.watch(sessionProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.huge,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Text('Wedding tinder', style: AppTypography.overline),
              AppSpacing.gapXl,
              EditorialHeading(
                style: AppTypography.displayLarge,
                spans: const [
                  EditorialSpan('Welcome '),
                  EditorialSpan('back', italic: true),
                  EditorialSpan('.'),
                ],
              ),
              AppSpacing.gapMd,
              Text(
                'Pick up planning right where you left off.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              AppSpacing.gapXxl,
              AppTextField(
                controller: _emailCtl,
                label: 'Email',
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: PhosphorIconsThin.envelopeSimple,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Invalid email'
                    : null,
              ),
              AppSpacing.gapLg,
              AppTextField(
                controller: _passwordCtl,
                label: 'Password',
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                prefixIcon: PhosphorIconsThin.lock,
                suffixIcon: PasswordRevealToggle(
                  revealed: _showPassword,
                  onTap: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
                onSubmitted: (_) => _submit(),
                validator: (v) => (v == null || v.length < 4)
                    ? 'Minimum 4 characters'
                    : null,
              ),
              AppSpacing.gapXxl,
              AppButton(
                label: 'Sign in',
                onPressed: _submit,
                isLoading: isLoading,
                fullWidth: true,
              ),
              AppSpacing.gapLg,
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/sign-up'),
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                      children: [
                        const TextSpan(text: 'Don\'t have an account? '),
                        TextSpan(
                          text: 'Create account',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
