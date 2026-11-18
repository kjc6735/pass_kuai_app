import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF4F1EA);
  static const surface = Colors.white;
  static const inputFill = Colors.white;

  static const primary = Color(0xFF5E7F63);
  static const primaryText = Color(0xFF3F6045);
  static const primarySoft = Color(0xFFE3ECDF);
  static const primarySoftText = Color(0xFF3F6045);
  static const primaryHalo = Color(0xFFD7E4D2);

  static const ink = Color(0xFF3D4A3A);
  static const inkSoft = Color(0xFF4B5847);
  static const sub = Color(0xFF626B5B);
  static const faint = Color(0xFFA7AC9C);

  static const line = Color(0xFFE4DED2);
  static const border = Color(0xFFD6CFC1);
  static const inputBorder = Color(0xFFE4DED2);
  static const track = Color(0xFFE6E1D6);
  static const segmentTrack = Color(0xFFEAE5DA);
  static const stackBack1 = Color(0xFFE8EEE3);
  static const stackBack2 = Color(0xFFEFF3EB);

  static const error = Color(0xFFB0302C);
  static const errorSoft = Color(0xFFFBEDEA);
}

Color toneColor(int tone) {
  switch (tone) {
    case 1:
      return const Color(0xFFD2454A);
    case 2:
      return const Color(0xFF2E8F62);
    case 3:
      return const Color(0xFF2D6CB8);
    case 4:
      return const Color(0xFF8752BA);
    default:
      return AppColors.sub;
  }
}

const cardShadow = <BoxShadow>[];

const primaryShadow = [
  BoxShadow(color: Color(0x475E7F63), blurRadius: 14, offset: Offset(0, 6)),
];

const floatingShadow = [
  BoxShadow(color: Color(0x0D3D4A3A), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x1F3D4A3A), blurRadius: 28, offset: Offset(0, 12)),
];

abstract final class AppWeights {
  static const hanzi = FontWeight.w500;
  static const hanziLarge = FontWeight.w400;
  static const pinyin = FontWeight.w500;
  static const title = FontWeight.w700;
  static const heading = FontWeight.w700;
  static const label = FontWeight.w600;
}

abstract final class AppFonts {
  static const family = 'Pretendard';
  static const fallback = <String>[
    'PingFang SC',
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'sans-serif',
  ];
}
