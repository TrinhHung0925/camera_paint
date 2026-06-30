import 'package:flutter/material.dart';

/// Tập trung toàn bộ màu sắc của app.
///
/// Quy chuẩn: KHÔNG hardcode `Color(0xFF...)` trong UI.
/// Mọi màu khai báo ở đây theo form `static const Color ffXXXXXX = Color(0xffXXXXXX);`
/// (tên = `ff` + 6 hex viết HOA) rồi tham chiếu qua `AppColors.ffXXXXXX`.
/// Màu có alpha đặt tên ngữ nghĩa riêng (vd `overlayDim`).
abstract class AppColors {
  static const Color ffFFFFFF = Color(0xffFFFFFF);
  static const Color ff000000 = Color(0xff000000);
  static const Color ff43A649 = Color(0xff43A649);
  static const Color ffE53935 = Color(0xffE53935);
  static const Color ff8E44AD = Color(0xff8E44AD);

  // --- Onboarding palette ---
  /// Nền tối màn splash (cinematic hook).
  static const Color ff0C0A07 = Color(0xff0C0A07);

  /// Cam thương hiệu (CTA, accent, chữ nghiêng).
  static const Color ffFF8C00 = Color(0xffFF8C00);
  static const Color ffF59E0B = Color(0xffF59E0B);
  static const Color ffC2691A = Color(0xffC2691A);

  /// Nền kem màn intro (the problem).
  static const Color ffF6EFE3 = Color(0xffF6EFE3);
  static const Color ffF8E8D0 = Color(0xffF8E8D0);

  /// Chữ eyebrow nâu-cam.
  static const Color ffB4773B = Color(0xffB4773B);

  /// Chữ headline gần đen (ấm).
  static const Color ff1A1714 = Color(0xff1A1714);

  /// Chữ phụ xám ấm.
  static const Color ff7A736B = Color(0xff7A736B);

  /// Label xám nhạt trong thẻ.
  static const Color ff9B948B = Color(0xff9B948B);

  /// Nền thẻ trắng kem.
  static const Color ffFDFBF7 = Color(0xffFDFBF7);

  /// Nền thẻ "With Plan Trips" (cam nhạt) + viền.
  static const Color ffFBEAD0 = Color(0xffFBEAD0);
  static const Color ffF8CD97 = Color(0xffF8CD97);

  /// Cam đậm (gradient CTA bên trái / chip giá).
  static const Color ffA15600 = Color(0xffA15600);

  /// Nền thẻ trung tính (stats, option chưa chọn).
  static const Color ffEFE9DF = Color(0xffEFE9DF);

  /// Viền nhạt trên nền kem.
  static const Color ffE7DECF = Color(0xffE7DECF);

  /// Nền pill nhấn cam nhạt (vd "2 hours saved").
  static const Color ffF7E2C0 = Color(0xffF7E2C0);

  /// Nền nút đen (Continue with Apple).
  static const Color ff1C1A17 = Color(0xff1C1A17);

  /// Overlay tối (alpha) — dùng cho lớp phủ mờ.
  static const Color overlayDim = Color(0x80000000);
}
