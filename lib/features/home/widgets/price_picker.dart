import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/editorial_heading.dart';

class PricePicker extends StatefulWidget {
  const PricePicker({
    super.key,
    required this.initialMin,
    required this.initialMax,
  });

  final int? initialMin;
  final int? initialMax;

  static Future<PriceRange?> show(
    BuildContext context, {
    int? initialMin,
    int? initialMax,
  }) {
    return showModalBottomSheet<PriceRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (_) => PricePicker(
        initialMin: initialMin,
        initialMax: initialMax,
      ),
    );
  }

  @override
  State<PricePicker> createState() => _PricePickerState();
}

class _PricePickerState extends State<PricePicker> {
  static const int _minRon = 0;
  static const int _maxRon = 50000;

  late RangeValues _values;

  @override
  void initState() {
    super.initState();
    _values = RangeValues(
      _toFraction(widget.initialMin ?? _minRon),
      _toFraction(widget.initialMax ?? _maxRon),
    );
  }

  int _snap(int ron) {
    if (ron < 1000) return (ron / 50).round() * 50;
    if (ron < 10000) return (ron / 250).round() * 250;
    return (ron / 1000).round() * 1000;
  }

  double _toFraction(int ron) =>
      ((ron - _minRon) / (_maxRon - _minRon)).clamp(0.0, 1.0);

  int _toRon(double fraction) =>
      _snap(_minRon + ((_maxRon - _minRon) * fraction).round());

  @override
  Widget build(BuildContext context) {
    final minRon = _toRon(_values.start);
    final maxRon = _toRon(_values.end);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text('FILTRU PREȚ', style: AppTypography.overline),
          AppSpacing.gapSm,
          EditorialHeading(
            style: AppTypography.headlineLarge,
            spans: const [
              EditorialSpan('Interval '),
              EditorialSpan('buget', italic: true),
              EditorialSpan('.'),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            'Se aplică la prețul listat al fiecărui vendor (per total sau per persoană).',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          AppSpacing.gapXl,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ValueChip(label: 'MINIM', value: Formatters.ron(minRon)),
              Icon(
                PhosphorIconsThin.arrowRight,
                size: 18,
                color: AppColors.onSurfaceMuted,
              ),
              _ValueChip(
                label: 'MAXIM',
                value: maxRon >= _maxRon
                    ? '${Formatters.ron(_maxRon)}+'
                    : Formatters.ron(maxRon),
              ),
            ],
          ),
          AppSpacing.gapMd,
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceVariant,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              trackHeight: 2,
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 9,
              ),
            ),
            child: RangeSlider(
              values: _values,
              onChanged: (v) => setState(() => _values = v),
            ),
          ),
          AppSpacing.gapXl,
          AppButton(
            label: 'Aplică filtrul',
            onPressed: () {
              Navigator.of(context).pop(
                PriceRange(
                  min: minRon <= _minRon ? null : minRon,
                  max: maxRon >= _maxRon ? null : maxRon,
                ),
              );
            },
            fullWidth: true,
          ),
          AppSpacing.gapSm,
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context)
                  .pop(const PriceRange(min: null, max: null)),
              child: Text(
                'Toate prețurile',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PriceRange {
  const PriceRange({required this.min, required this.max});
  final int? min;
  final int? max;
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.overline.copyWith(letterSpacing: 1.4),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
