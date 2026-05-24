import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/judete.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/editorial_heading.dart';

class JudetPicker extends StatefulWidget {
  const JudetPicker({super.key, required this.initial});

  final String? initial;

  static Future<String?> show(BuildContext context, {String? initial}) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => JudetPicker(initial: initial),
    );
  }

  @override
  State<JudetPicker> createState() => _JudetPickerState();
}

class _JudetPickerState extends State<JudetPicker> {
  final _queryCtl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? kJudete
        : kJudete.where((j) => _matches(j, _query)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtl) {
        return Column(
          children: [
            AppSpacing.gapMd,
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadii.fullAll,
                ),
              ),
            ),
            AppSpacing.gapLg,
            Padding(
              padding: AppSpacing.horizontalLg,
              child: EditorialHeading(
                style: AppTypography.displaySmall,
                spans: const [
                  EditorialSpan('Alege '),
                  EditorialSpan('județul', italic: true),
                ],
              ),
            ),
            AppSpacing.gapLg,
            Padding(
              padding: AppSpacing.horizontalLg,
              child: _SearchField(
                controller: _queryCtl,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: ListView.builder(
                controller: scrollCtl,
                itemCount: filtered.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _JudetRow(
                      label: 'Toate județele',
                      selected: widget.initial == null,
                      onTap: () => Navigator.of(context).pop(''),
                    );
                  }
                  final judet = filtered[i - 1];
                  return _JudetRow(
                    label: judet,
                    selected: judet == widget.initial,
                    onTap: () => Navigator.of(context).pop(judet),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static String _normalize(String s) {
    const map = {
      'ă': 'a', 'â': 'a', 'î': 'i', 'ș': 's', 'ş': 's', 'ț': 't', 'ţ': 't',
      'Ă': 'a', 'Â': 'a', 'Î': 'i', 'Ș': 's', 'Ş': 's', 'Ț': 't', 'Ţ': 't',
    };
    final buf = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      buf.write(map[ch] ?? ch);
    }
    return buf.toString();
  }

  static bool _matches(String haystack, String needle) {
    return _normalize(haystack).contains(_normalize(needle));
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.mdAll,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          const Icon(
            PhosphorIconsThin.magnifyingGlass,
            size: 20,
            color: AppColors.onSurfaceMuted,
          ),
          AppSpacing.gapSm,
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Caută județ',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JudetRow extends StatelessWidget {
  const _JudetRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.surfaceVariant,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: selected ? AppColors.primary : AppColors.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(
                PhosphorIconsThin.check,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
