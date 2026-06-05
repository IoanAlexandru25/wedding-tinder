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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(sessionProvider.notifier).signUp(
          email: _emailCtl.text.trim(),
          password: _passwordCtl.text,
          displayName: _nameCtl.text.trim(),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsThin.arrowLeft),
          onPressed: () => context.go('/sign-in'),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              EditorialHeading(
                style: AppTypography.displayLarge,
                spans: const [
                  EditorialSpan('Let\'s '),
                  EditorialSpan('get started', italic: true),
                  EditorialSpan('.'),
                ],
              ),
              AppSpacing.gapMd,
              Text(
                'A few details and you\'re on your way.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.of(context).onSurfaceMuted,
                ),
              ),
              AppSpacing.gapXxl,
              AppTextField(
                controller: _nameCtl,
                label: 'Full name',
                hintText: 'Alex Smith',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                prefixIcon: PhosphorIconsThin.user,
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Minimum 2 characters'
                    : null,
              ),
              AppSpacing.gapLg,
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
                textInputAction: TextInputAction.next,
                prefixIcon: PhosphorIconsThin.lock,
                suffixIcon: PasswordRevealToggle(
                  revealed: _showPassword,
                  onTap: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
                helperText:
                    'Minimum 6 characters · toggle applies to both fields',
                validator: (v) => (v == null || v.length < 6)
                    ? 'Minimum 6 characters'
                    : null,
              ),
              AppSpacing.gapLg,
              AppTextField(
                controller: _confirmCtl,
                label: 'Confirm password',
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                prefixIcon: PhosphorIconsThin.lock,
                onSubmitted: (_) => _submit(),
                validator: (v) => (v != _passwordCtl.text)
                    ? 'Passwords do not match'
                    : null,
              ),
              AppSpacing.gapXxl,
              AppButton(
                label: 'Create account',
                onPressed: _submit,
                isLoading: isLoading,
                fullWidth: true,
              ),
              AppSpacing.gapLg,
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/sign-in'),
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.of(context).onSurfaceMuted,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.of(context).primary,
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
