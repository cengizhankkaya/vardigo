import 'package:flutter/material.dart';

import '../../core/presentation/widgets/brand_logo.dart';

/// A single, finite introduction over the already-mounted router.
/// Deep links and automatic demo login can resolve underneath it without
/// adding a splash route to the back stack or restarting on theme changes.
class StartupBranding extends StatefulWidget {
  const StartupBranding({super.key, required this.child});

  final Widget child;

  @override
  State<StartupBranding> createState() => _StartupBrandingState();
}

class _StartupBrandingState extends State<StartupBranding>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final CurvedAnimation _entrance;
  late final CurvedAnimation _exit;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _intro =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1500),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted && !_finished) {
            setState(() => _finished = true);
          }
        });
    _entrance = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.48, curve: Curves.easeOutCubic),
    );
    _exit = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.76, 1, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _finished = true;
      _intro.stop();
    } else if (!_started && !_finished) {
      _started = true;
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _exit.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: !_finished,
          child: ExcludeFocus(
            excluding: !_finished,
            child: ExcludeSemantics(excluding: !_finished, child: widget.child),
          ),
        ),
        if (!_finished)
          Positioned.fill(
            child: AbsorbPointer(
              child: AnimatedBuilder(
                animation: _intro,
                builder: (context, _) => Opacity(
                  opacity: 1 - _exit.value,
                  child: ColoredBox(
                    color: scheme.surface,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.12),
                          radius: 0.85,
                          colors: [
                            scheme.primary.withValues(alpha: 0.09),
                            scheme.surface.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: 0.25 + 0.75 * _entrance.value,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - _entrance.value)),
                            child: Transform.scale(
                              scale: 0.9 + 0.1 * _entrance.value,
                              child: LayoutBuilder(
                                builder: (context, constraints) => BrandLogo(
                                  size: (constraints.biggest.shortestSide * 0.6)
                                      .clamp(120.0, 240.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
