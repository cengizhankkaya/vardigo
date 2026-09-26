import 'app_sizes.dart';

/// Reference phone frame geometry (design tokens, "TELEFON ÇERÇEVESİ").
abstract final class AppFrame {
  static const double width = AppSizes.frameWidth;
  static const double height = AppSizes.frameHeight;
  static const double outerRadius = 54;
  static const double screenRadius = 44;
  static const double bezel = 11;

  static const double statusBarHeight = 54;
  static const double statusSideInset = 24;
  static const double statusTop = 16;
  static const double statusSlotWidth = 100;
  static const double levelsHeight = 22;

  static const double islandWidth = 126;
  static const double islandHeight = 37;
  static const double islandTop = 11;
  static const double islandLens = 10;
  static const double islandLensInset = 14;

  static const double homeAreaHeight = 30;
  static const double homePillWidth = 135;
  static const double homePillHeight = 5;
  static const double homePillBottom = 8;
}
