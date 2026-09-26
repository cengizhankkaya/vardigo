import 'package:flutter/material.dart';

import '../../../gen/colors.gen.dart';
import '../tokens/app_text_styles.dart';

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
        style: AppTextStyles.label14.copyWith(
          color: ColorName.sub,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
