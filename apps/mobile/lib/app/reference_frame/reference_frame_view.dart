import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'phone_frame.dart';

/// Shows [child] inside a [PhoneFrame] centred on the device, scaled down in
/// one ratio when the screen is smaller than the frame. Enabled with
/// `--dart-define=REFERENCE_FRAME=true`.
class ReferenceFrameView extends StatelessWidget {
  const ReferenceFrameView({super.key, required this.child});

  static const enabled = bool.fromEnvironment('REFERENCE_FRAME');

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.appColors.backdrop,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FittedBox(child: PhoneFrame(child: child)),
          ),
        ),
      ),
    );
  }
}
