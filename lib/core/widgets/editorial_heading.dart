import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

class EditorialHeading extends StatelessWidget {
  const EditorialHeading({
    super.key,
    required this.spans,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final List<EditorialSpan> spans;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppTypography.displayMedium;
    final italicStyle = base.copyWith(fontStyle: FontStyle.italic);
    return Text.rich(
      TextSpan(
        children: spans
            .map((s) => TextSpan(
                  text: s.text,
                  style: s.italic ? italicStyle : base,
                ))
            .toList(),
      ),
      textAlign: textAlign,
    );
  }
}

class EditorialSpan {
  const EditorialSpan(this.text, {this.italic = false});
  final String text;
  final bool italic;
}
