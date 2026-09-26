import 'package:flutter/material.dart';

import '../../../../gen/colors.gen.dart';
import '../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../shared/design_system/tokens/app_shadows.dart';
import '../../../../shared/design_system/tokens/app_text_styles.dart';

/// One demo account: title, hint and a chevron, or a spinner while logging in.
class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.title,
    required this.hint,
    required this.loading,
    required this.onTap,
  });

  final String title;
  final String hint;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorName.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: ColorName.slate200),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.title18),
                    const SizedBox(height: 4),
                    Text(hint, style: AppTextStyles.caption12),
                  ],
                ),
              ),
              if (loading)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right, color: ColorName.slate500),
            ],
          ),
        ),
      ),
    );
  }
}
