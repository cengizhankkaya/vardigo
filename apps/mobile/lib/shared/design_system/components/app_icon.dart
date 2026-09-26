import 'package:flutter/widgets.dart';

import '../../../gen/assets.gen.dart';

/// Draws a case icon in a [size] square: `AppIcon(Assets.icons.star)`.
///
/// Without [color] the SVG keeps its own colours (multi-colour icons such as
/// shield or online). With [color] the whole shape is tinted, for the
/// single-colour mask icons (star, check, close, eye...).
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 16, this.color});

  final SvgGenImage icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    return ExcludeSemantics(
      child: icon.svg(
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
