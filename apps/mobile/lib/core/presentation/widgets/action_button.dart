import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../theme/theme.dart';
import '../../theme/tokens/app_dimens.dart';
import 'app_icon.dart';

/// Short icon + label button used inside cards. Dimmed when [onTap] is null.
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.foreground,
    required this.onTap,
    this.background,
    this.border,
  });

  final SvgGenImage icon;
  final String label;
  final Color foreground;
  final Color? background;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final border = this.border;
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.45 : 1,
          child: Container(
            height: AppSizes.actionButton,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.actionButton),
              border: border == null ? null : Border.all(color: border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(icon, size: 16, color: foreground),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.label14.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
