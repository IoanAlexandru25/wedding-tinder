import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/editorial_heading.dart';
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
              Text('MIRI', style: AppTypography.overline),
              AppSpacing.gapXl,
              EditorialHeading(
                style: AppTypography.displayLarge,
                spans: const [
                  EditorialSpan('Bună '),
                  EditorialSpan('revenire', italic: true),
                  EditorialSpan('.'),
                ],
              ),
              AppSpacing.gapMd,
              Text(
                'Continuăm planificarea de unde ați rămas.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              AppSpacing.gapXxl,
              AppTextField(
                controller: _emailCtl,
                label: 'Email',
                hintText: 'tu@exemplu.ro',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: PhosphorIconsThin.envelopeSimple,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Email invalid'
                    : null,
              ),
              AppSpacing.gapLg,
              AppTextField(
                controller: _passwordCtl,
                label: 'Parolă',
                obscureText: true,
                textInputAction: TextInputAction.done,
                prefixIcon: PhosphorIconsThin.lock,
                onSubmitted: (_) => _submit(),
                validator: (v) => (v == null || v.length < 4)
                    ? 'Minimum 4 caractere'
                    : null,
              ),
              AppSpacing.gapXxl,
              AppButton(
                label: 'Autentificare',
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
                        const TextSpan(text: 'Nu ai cont? '),
                        TextSpan(
                          text: 'Creează cont',
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
