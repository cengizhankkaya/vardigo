import 'package:flutter/material.dart';

import '../../../../shared/design_system/theme/theme.dart';
import '../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../shared/design_system/tokens/app_shadows.dart';

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
    final colors = context.appColors;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: colors.border),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.title18),
                    const SizedBox(height: 4),
                    Text(hint, style: context.textStyles.caption12),
                  ],
                ),
              ),
              if (loading)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.chevron_right, color: colors.textInactive),
            ],
          ),
        ),
      ),
    );
  }
}
