import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/theme/tokens/app_shadows.dart';

/// One demo account: title, hint and a chevron, or a spinner while logging in.
class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.loading,
    required this.onTap,
  });

  final String title;
  final String hint;
  final IconData icon;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.card,
        ),
        child: Material(
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: colors.border),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).primary
                          .withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(
                        AppRadius.squareButton,
                      ),
                    ),
                    child: Icon(icon, color: colors.accent, size: 23),
                  ),
                  const SizedBox(width: 14),
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
                  const SizedBox(width: 8),
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
        ),
      ),
    );
  }
}
