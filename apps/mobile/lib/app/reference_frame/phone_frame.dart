import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/tokens/app_frame.dart';
import '../../core/theme/tokens/app_radius.dart';
import '../../core/theme/tokens/app_shadows.dart';
import '../../gen/assets.gen.dart';
import '../../gen/colors.gen.dart';

/// The case's reference phone: 390×844 with a black bezel, Dynamic Island,
/// 9:41 status bar and home pill, drawn around [child].
///
/// [child] lays out on the 368×822 inner screen. It sees the status bar and
/// home area as safe-area padding, so screens keep using [SafeArea] and look
/// the same as in the reference PNGs.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  static const screenSize = Size(
    AppFrame.width - AppFrame.bezel * 2,
    AppFrame.height - AppFrame.bezel * 2,
  );

  static const _safeArea = EdgeInsets.only(
    top: AppFrame.statusBarHeight,
    bottom: AppFrame.homeAreaHeight,
  );

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      width: AppFrame.width,
      height: AppFrame.height,
      padding: const EdgeInsets.all(AppFrame.bezel),
      decoration: BoxDecoration(
        color: ColorName.bezel,
        borderRadius: BorderRadius.circular(AppFrame.outerRadius),
        boxShadow: AppShadows.bezel,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppFrame.outerRadius),
        // Inner highlight: inset 0 0 0 1 rgba(255,255,255,0.12).
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppFrame.screenRadius),
        child: Stack(
          children: [
            Positioned.fill(
              child: MediaQuery(
                data: media.copyWith(
                  size: screenSize,
                  padding: _safeArea,
                  viewPadding: _safeArea,
                  viewInsets: EdgeInsets.zero,
                ),
                child: child,
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(child: _StatusBar()),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: AppFrame.homePillBottom,
              child: IgnorePointer(child: _HomePill()),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: AppFrame.statusBarHeight,
        child: Stack(
          children: [
            Positioned(
              left: AppFrame.statusSideInset,
              top: AppFrame.statusTop,
              width: AppFrame.statusSlotWidth,
              // The frame sits above the Navigator, outside any Material, so
              // the style is set whole rather than merged with the fallback.
              child: DefaultTextStyle(
                style: context.textStyles.statusTime,
                child: const Text('9:41', textAlign: TextAlign.center),
              ),
            ),
            const Positioned(
              top: AppFrame.islandTop,
              left: 0,
              right: 0,
              child: Center(child: _DynamicIsland()),
            ),
            Positioned(
              right: AppFrame.statusSideInset,
              top: AppFrame.statusTop,
              child: Assets.icons.levels.svg(
                width: AppFrame.statusSlotWidth,
                height: AppFrame.levelsHeight,
                colorFilter: ColorFilter.mode(
                  context.appColors.textStrong,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppFrame.islandWidth,
      height: AppFrame.islandHeight,
      padding: const EdgeInsets.only(right: AppFrame.islandLensInset),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: ColorName.island,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Container(
        width: AppFrame.islandLens,
        height: AppFrame.islandLens,
        decoration: BoxDecoration(
          color: ColorName.islandLens,
          shape: BoxShape.circle,
          border: Border.all(color: ColorName.islandRing),
        ),
      ),
    );
  }
}

class _HomePill extends StatelessWidget {
  const _HomePill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppFrame.homePillWidth,
        height: AppFrame.homePillHeight,
        decoration: BoxDecoration(
          color: ColorName.homePill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}
