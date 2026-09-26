import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Centered text shown in place of an empty list.
class EmptyView extends StatelessWidget {
  const EmptyView(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.textStyles.label14.copyWith(
          color: context.appColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
