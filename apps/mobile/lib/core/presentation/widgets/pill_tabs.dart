import 'package:flutter/material.dart';

/// Colors and sizes of one [PillTabs] design; each screen has its own.
class PillTabsStyle {
  const PillTabsStyle({
    required this.background,
    required this.radius,
    required this.pillRadius,
    required this.pillPadding,
    required this.activeColor,
    required this.activeShadow,
    required this.textStyle,
    required this.activeTextColor,
    required this.inactiveTextColor,
    this.gap = 0,
  });

  final Color background;
  final double radius;
  final double pillRadius;
  final EdgeInsets pillPadding;
  final Color activeColor;
  final List<BoxShadow> activeShadow;
  final TextStyle textStyle;
  final Color activeTextColor;
  final Color inactiveTextColor;

  /// Space between pills.
  final double gap;
}

/// Equal-width tabs in a rounded track; the active one is a raised pill.
class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    required this.style,
  });

  /// Value and label of each tab, in order.
  final List<(T, String)> tabs;
  final T selected;
  final ValueChanged<T> onSelected;
  final PillTabsStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(style.radius),
      ),
      child: Row(
        children: [
          for (final (index, (value, label)) in tabs.indexed) ...[
            if (index > 0 && style.gap > 0) SizedBox(width: style.gap),
            Expanded(
              child: _Pill(
                label: label,
                active: value == selected,
                style: style,
                onTap: () => onSelected(value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.active,
    required this.style,
    required this.onTap,
  });

  final String label;
  final bool active;
  final PillTabsStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: style.pillPadding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? style.activeColor : null,
            borderRadius: BorderRadius.circular(style.pillRadius),
            boxShadow: active ? style.activeShadow : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.textStyle.copyWith(
              color: active ? style.activeTextColor : style.inactiveTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
