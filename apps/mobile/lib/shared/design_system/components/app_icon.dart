import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_icons.dart';

/// Draws a case icon in a [size] square.
///
/// Without [color] the SVG keeps its own colours (multi-colour icons such as
/// shield or online). With [color] the whole shape is tinted, for the
/// single-colour mask icons (star, check, close, eye...).
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 16, this.color});

  final AppIcons icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    return ExcludeSemantics(
      child: SvgPicture.asset(
        icon.path,
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
