import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/editorial_heading.dart';
import '../../providers/session_provider.dart';

class WeddingEditScreen extends ConsumerStatefulWidget {
  const WeddingEditScreen({super.key});

  @override
  ConsumerState<WeddingEditScreen> createState() => _WeddingEditScreenState();
}

class _WeddingEditScreenState extends ConsumerState<WeddingEditScreen> {
  late DateTime _start;
  late DateTime _end;
  late final TextEditingController _guestsCtl;
  late final TextEditingController _budgetMinCtl;
  late final TextEditingController _budgetMaxCtl;

  @override
  void initState() {
    super.initState();
    final w = ref.read(sessionProvider).wedding!;
    _start = w.weddingDateStart;
    _end = w.weddingDateEnd;
    _guestsCtl = TextEditingController(text: '${w.guestCount}');
    _budgetMinCtl = TextEditingController(text: '${w.budgetMin}');
    _budgetMaxCtl = TextEditingController(text: '${w.budgetMax}');
  }

  @override
  void dispose() {
    _guestsCtl.dispose();
    _budgetMinCtl.dispose();
    _budgetMaxCtl.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _start, end: _end),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Choose the wedding date',
      saveText: 'Save',
      cancelText: 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.of(context).primary,
                  onPrimary: AppColors.of(context).onPrimary,
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

  Future<void> _save() async {
    final guests = int.tryParse(_guestsCtl.text);
    final bMin = int.tryParse(_budgetMinCtl.text);
    final bMax = int.tryParse(_budgetMaxCtl.text);
    if (guests == null || guests <= 0 || bMin == null || bMax == null || bMin > bMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check the details you entered.')),
      );
      return;
    }
    await ref.read(sessionProvider.notifier).updateWedding(
          weddingDateStart: _start,
          weddingDateEnd: _end,
          guestCount: guests,
          budgetMin: bMin,
          budgetMax: bMax,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Details saved.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(sessionProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsThin.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EDIT WEDDING',
          style: AppTypography.overline.copyWith(letterSpacing: 1.6),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.huge,
          ),
          children: [
            EditorialHeading(
              style: AppTypography.displayMedium,
              spans: const [
                EditorialSpan('Adjust '),
                EditorialSpan('the details', italic: true),
                EditorialSpan('.'),
              ],
            ),
            AppSpacing.gapMd,
            Text(
              'Changes apply immediately across the app.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.of(context).onSurfaceMuted,
              ),
            ),
            AppSpacing.gapXl,
            GestureDetector(
              onTap: _pickRange,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.of(context).borderStrong),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEDDING DATE',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.of(context).primary,
                      ),
                    ),
                    AppSpacing.gapSm,
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsThin.calendarBlank,
                          size: 20,
                          color: AppColors.of(context).onSurfaceMuted,
                        ),
                        AppSpacing.gapSm,
                        Expanded(
                          child: Text(
                            '${Formatters.longDate(_start)} — ${Formatters.longDate(_end)}',
                            style: AppTypography.bodyLarge,
                          ),
                        ),
                        Icon(
                          PhosphorIconsThin.caretRight,
                          size: 18,
                          color: AppColors.of(context).onSurfaceMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.gapLg,
            AppTextField(
              controller: _guestsCtl,
              label: 'Guest count',
              keyboardType: TextInputType.number,
              prefixIcon: PhosphorIconsThin.users,
            ),
            AppSpacing.gapLg,
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _budgetMinCtl,
                    label: 'Min budget (RON)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: AppTextField(
                    controller: _budgetMaxCtl,
                    label: 'Max budget (RON)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            AppSpacing.gapXxl,
            AppButton(
              label: 'Save changes',
              onPressed: _save,
              isLoading: isLoading,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
