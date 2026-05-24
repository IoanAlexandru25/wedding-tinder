import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/editorial_heading.dart';
import '../../providers/session_provider.dart';

enum _SetupMode { create, join }

class WeddingSetupScreen extends ConsumerStatefulWidget {
  const WeddingSetupScreen({super.key});

  @override
  ConsumerState<WeddingSetupScreen> createState() =>
      _WeddingSetupScreenState();
}

class _WeddingSetupScreenState extends ConsumerState<WeddingSetupScreen> {
  _SetupMode _mode = _SetupMode.create;

  // Create form state
  DateTime _start = DateTime(2026, 6, 12);
  DateTime _end = DateTime(2026, 6, 13);
  final _guestsCtl = TextEditingController(text: '150');
  final _budgetMinCtl = TextEditingController(text: '60000');
  final _budgetMaxCtl = TextEditingController(text: '80000');

  // Join form state
  final _codeCtl = TextEditingController();

  @override
  void dispose() {
    _guestsCtl.dispose();
    _budgetMinCtl.dispose();
    _budgetMaxCtl.dispose();
    _codeCtl.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _start, end: _end),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Alegeți data nunții',
      saveText: 'Salvează',
      cancelText: 'Anulează',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: AppColors.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
      });
    }
  }

  Future<void> _submitCreate() async {
    final guests = int.tryParse(_guestsCtl.text);
    final bMin = int.tryParse(_budgetMinCtl.text);
    final bMax = int.tryParse(_budgetMaxCtl.text);
    if (guests == null || bMin == null || bMax == null || bMin > bMax) {
      _showError('Verifică datele introduse.');
      return;
    }
    await ref.read(sessionProvider.notifier).createWedding(
          weddingDateStart: _start,
          weddingDateEnd: _end,
          guestCount: guests,
          budgetMin: bMin,
          budgetMax: bMax,
        );
  }

  Future<void> _submitJoin() async {
    await ref
        .read(sessionProvider.notifier)
        .joinWedding(_codeCtl.text);
    final err = ref.read(sessionProvider).error;
    if (err != null && mounted) _showError(err);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            Text('PASUL FINAL', style: AppTypography.overline),
            AppSpacing.gapMd,
            EditorialHeading(
              style: AppTypography.displayLarge,
              spans: const [
                EditorialSpan('Spuneți-ne despre '),
                EditorialSpan('nunta voastră', italic: true),
                EditorialSpan('.'),
              ],
            ),
            AppSpacing.gapMd,
            Text(
              'Vom personaliza recomandările pe baza acestor detalii.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
            AppSpacing.gapXl,
            _ModeToggle(
              mode: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
            AppSpacing.gapXl,
            if (_mode == _SetupMode.create)
              _CreateForm(
                start: _start,
                end: _end,
                guestsCtl: _guestsCtl,
                budgetMinCtl: _budgetMinCtl,
                budgetMaxCtl: _budgetMaxCtl,
                onPickRange: _pickRange,
              )
            else
              _JoinForm(codeCtl: _codeCtl),
            AppSpacing.gapXxl,
            AppButton(
              label: _mode == _SetupMode.create
                  ? 'Creează nunta'
                  : 'Alătură-te nunții',
              onPressed: _mode == _SetupMode.create ? _submitCreate : _submitJoin,
              isLoading: session.isLoading,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});
  final _SetupMode mode;
  final ValueChanged<_SetupMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.mdAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Creează',
              selected: mode == _SetupMode.create,
              onTap: () => onChanged(_SetupMode.create),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Cod invitație',
              selected: mode == _SetupMode.join,
              onTap: () => onChanged(_SetupMode.join),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: AppRadii.smAll,
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: AppTypography.overline.copyWith(
            color: selected ? AppColors.onSurface : AppColors.onSurfaceMuted,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class _CreateForm extends StatelessWidget {
  const _CreateForm({
    required this.start,
    required this.end,
    required this.guestsCtl,
    required this.budgetMinCtl,
    required this.budgetMaxCtl,
    required this.onPickRange,
  });

  final DateTime start;
  final DateTime end;
  final TextEditingController guestsCtl;
  final TextEditingController budgetMinCtl;
  final TextEditingController budgetMaxCtl;
  final VoidCallback onPickRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onPickRange,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderStrong),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATA NUNȚII',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.gapSm,
                Row(
                  children: [
                    Icon(
                      PhosphorIconsThin.calendarBlank,
                      size: 20,
                      color: AppColors.onSurfaceMuted,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      '${Formatters.longDate(start)} — ${Formatters.longDate(end)}',
                      style: AppTypography.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AppSpacing.gapLg,
        AppTextField(
          controller: guestsCtl,
          label: 'Număr invitați',
          keyboardType: TextInputType.number,
          prefixIcon: PhosphorIconsThin.users,
        ),
        AppSpacing.gapLg,
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: budgetMinCtl,
                label: 'Buget min (RON)',
                keyboardType: TextInputType.number,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: AppTextField(
                controller: budgetMaxCtl,
                label: 'Buget max (RON)',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JoinForm extends StatelessWidget {
  const _JoinForm({required this.codeCtl});
  final TextEditingController codeCtl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Introdu codul primit de la partener.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
        AppSpacing.gapLg,
        AppTextField(
          controller: codeCtl,
          label: 'Cod invitație',
          hintText: 'WED-XXXX',
          prefixIcon: PhosphorIconsThin.envelope,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
