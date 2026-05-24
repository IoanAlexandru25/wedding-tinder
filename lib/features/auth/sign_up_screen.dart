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
                  EditorialSpan('Hai să '),
                  EditorialSpan('începem', italic: true),
                  EditorialSpan('.'),
                ],
              ),
              AppSpacing.gapMd,
              Text(
                'Câteva detalii și sunteți pe drum.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              AppSpacing.gapXxl,
              AppTextField(
                controller: _nameCtl,
                label: 'Nume complet',
                hintText: 'Maria Popescu',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                prefixIcon: PhosphorIconsThin.user,
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Minimum 2 caractere'
                    : null,
              ),
              AppSpacing.gapLg,
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
                textInputAction: TextInputAction.next,
                prefixIcon: PhosphorIconsThin.lock,
                helperText: 'Minimum 6 caractere',
                validator: (v) => (v == null || v.length < 6)
                    ? 'Minimum 6 caractere'
                    : null,
              ),
              AppSpacing.gapLg,
              AppTextField(
                controller: _confirmCtl,
                label: 'Confirmă parola',
                obscureText: true,
                textInputAction: TextInputAction.done,
                prefixIcon: PhosphorIconsThin.lock,
                onSubmitted: (_) => _submit(),
                validator: (v) => (v != _passwordCtl.text)
                    ? 'Parolele nu se potrivesc'
                    : null,
              ),
              AppSpacing.gapXxl,
              AppButton(
                label: 'Creează cont',
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
                        color: AppColors.onSurfaceMuted,
                      ),
                      children: [
                        const TextSpan(text: 'Ai deja cont? '),
                        TextSpan(
                          text: 'Autentifică-te',
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
