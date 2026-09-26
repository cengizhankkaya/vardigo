import 'package:flutter/painting.dart';

/// Box shadows from the case design tokens.
abstract final class AppShadows {
  /// Cards: 0 2 4 rgba(36,61,130,0.04).
  static const card = [
    BoxShadow(color: Color(0x0A243D82), offset: Offset(0, 2), blurRadius: 4),
  ];

  /// Selected candidate card: 0 2 8 rgba(36,61,130,0.04). The 4 px blue
  /// left edge (CSS inset shadow) is drawn by the card itself.
  static const cardSelected = [
    BoxShadow(color: Color(0x0A243D82), offset: Offset(0, 2), blurRadius: 8),
  ];

  /// Back / help buttons: 0 1 2 rgba(10,13,20,0.08).
  static const squareButton = [
    BoxShadow(color: Color(0x140A0D14), offset: Offset(0, 1), blurRadius: 2),
  ];

  /// Sort chip: 0 2 4 rgba(0,0,0,0.04).
  static const chip = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  /// Active tab on "Eşleşen Personeller": 0 6 5 / 0 2 2 rgba(14,18,27,…).
  static const candidateTabActive = [
    BoxShadow(color: Color(0x0F0E121B), offset: Offset(0, 6), blurRadius: 5),
    BoxShadow(color: Color(0x080E121B), offset: Offset(0, 2), blurRadius: 2),
  ];

  /// Active tab on "Görüşme Talepleri": 0 6 10 / 0 2 4 rgba(14,18,27,…).
  static const offerTabActive = [
    BoxShadow(color: Color(0x0F0E121B), offset: Offset(0, 6), blurRadius: 10),
    BoxShadow(color: Color(0x080E121B), offset: Offset(0, 2), blurRadius: 4),
  ];

  /// Reference phone bezel: 0 28 48 rgba(15,18,27,0.22).
  static const bezel = [
    BoxShadow(color: Color(0x380F121B), offset: Offset(0, 28), blurRadius: 48),
  ];
}
