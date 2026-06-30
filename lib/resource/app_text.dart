import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Tập trung các TextStyle dùng chung của app.
///
/// - `Newsreader`: serif tương phản cao — dùng cho headline.
/// - `Plus Jakarta Sans`: sans hiện đại — dùng cho body/UI.
///
/// Dùng `.sp` (flutter_screenutil) cho fontSize để responsive theo design 390x884.
abstract class AppText {
  static const String serif = 'Newsreader';
  static const String sans = 'PlusJakartaSans';

  /// Headline serif (Newsreader). [italic] cho phần nhấn nghiêng.
  static TextStyle headline(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.ff1A1714,
    bool italic = false,
    double height = 1.1,
  }) =>
      TextStyle(
        fontFamily: serif,
        fontSize: size.sp,
        fontWeight: weight,
        color: color,
        height: height,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  /// Text sans (Plus Jakarta Sans).
  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ff1A1714,
    double height = 1.4,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size.sp,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Eyebrow small-caps (vd "THE PROBLEM").
  static TextStyle eyebrow(Color color) => TextStyle(
        fontFamily: sans,
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.5,
      );

  // Một vài preset tiện dùng chung.
  static TextStyle get regular14 => body(14);
  static TextStyle get medium16 => body(16, weight: FontWeight.w500);
  static TextStyle get bold20 => headline(20, weight: FontWeight.w700);
}
