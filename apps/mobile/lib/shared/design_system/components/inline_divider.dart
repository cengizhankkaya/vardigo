import 'package:flutter/material.dart';

import '../../../gen/colors.gen.dart';

/// Thin vertical line between items on one line ("4.9 | %100 | 1.2 km").
class InlineDivider extends StatelessWidget {
  const InlineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: ColorName.slate200,
    );
  }
}
