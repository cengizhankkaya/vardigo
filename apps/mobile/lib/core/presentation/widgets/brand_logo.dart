import 'package:flutter/widgets.dart';

import '../../../gen/assets.gen.dart';
import '../../l10n/l10n.dart';

/// The same brand artwork on launch and sign-in surfaces.
/// Decorative instances never duplicate the brand's screen-reader label.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 200,
    this.opacity = 1,
    this.decorative = false,
  });

  final double size;
  final double opacity;
  final bool decorative;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: opacity,
    child: Assets.branding.vardigoSplashLogo.image(
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: decorative,
      semanticLabel: decorative ? null : context.l10n.appTitle,
    ),
  );
}
