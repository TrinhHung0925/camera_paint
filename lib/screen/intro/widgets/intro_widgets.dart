import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';

export '../../../common/reveal.dart' show RevealGroup, RevealItem;

/// Gradient nền kem dùng chung cho các trang onboarding sáng.
const kCreamGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.ffF8E8D0, AppColors.ffF6EFE3],
  stops: [0.0, 0.35],
);

/// Khung chuẩn cho 1 trang onboarding nền kem: nền gradient + SafeArea + padding.
/// Truyền [child] là toàn bộ nội dung cột của trang.
class IntroScaffold extends StatelessWidget {
  const IntroScaffold({
    super.key,
    required this.child,
    this.decoration,
  });

  final Widget child;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration ?? const BoxDecoration(gradient: kCreamGradient),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: child,
        ),
      ),
    );
  }
}

/// Pill nhỏ ở góc trên (Back / Skip / Not now).
class TopPill extends StatelessWidget {
  const TopPill({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColors.ffFFFFFF,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.ff000000.withValues(alpha: 0.06),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(text,
            style: AppText.body(14,
                weight: FontWeight.w600, color: AppColors.ff1A1714)),
      ),
    );
  }
}

/// Hàng top bar chuẩn cho mọi màn intro:
/// [IntroProgressBar] bên trái + pill (Back/Skip/Not now) bên phải.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.index,
    required this.pillText,
    required this.onPill,
    this.onDark = false,
  });

  /// Vị trí trang hiện tại (0-based) trong tổng số trang onboarding.
  final int index;
  final String pillText;
  final VoidCallback onPill;

  /// true khi đặt trên nền tối/ảnh (đổi màu các step mờ cho dễ nhìn).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,

      width: double.infinity,
      child: Stack(
        children: [
          Align(alignment: Alignment.center,child: IntroProgressBar(current: index, onDark: onDark)),
          Align(alignment: Alignment.centerRight,child: TopPill(text: pillText, onTap: onPill)),
        ],
      ),
    );
  }
}

/// Thanh tiến trình dạng stepper: mỗi trang một đốt; các đốt đã qua + hiện tại
/// màu cam, đốt hiện tại dài hơn, đốt sắp tới mờ.
class IntroProgressBar extends StatelessWidget {
  const IntroProgressBar({
    super.key,
    required this.current,
    this.total = 13,
    this.onDark = false,
  });

  final int current;
  final int total;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final faint = onDark
        ? AppColors.ffFFFFFF.withValues(alpha: 0.28)
        : AppColors.ff1A1714.withValues(alpha: 0.14);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isCurrent = i == current;
        return Container(
          margin: EdgeInsets.only(right: 5.w),
          width: isCurrent ? 16.w : 5.w,
          height: 5.w,
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.ffFF8C00 : faint,
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}

/// Eyebrow small-caps cam-nâu (vd "HOW IT WORKS").
class IntroEyebrow extends StatelessWidget {
  const IntroEyebrow(this.text, {super.key, this.color = AppColors.ffB4773B});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppText.eyebrow(color));
  }
}

/// Headline serif. Phần nằm trong [italicParts] (so khớp chuỗi con) được in nghiêng.
/// Ví dụ: IntroHeadline('Watch AI\norganize everything.', italic: 'everything.')
class IntroHeadline extends StatelessWidget {
  const IntroHeadline(
    this.text, {
    super.key,
    this.italic,
    this.size = 30,
    this.color = AppColors.ff1A1714,
  });

  final String text;
  final String? italic;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final base = AppText.headline(size, weight: FontWeight.w500, color: color);
    if (italic == null || !text.contains(italic!)) {
      return Text(text, style: base);
    }
    final idx = text.indexOf(italic!);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
              text: italic,
              style: const TextStyle(fontStyle: FontStyle.italic)),
          TextSpan(text: text.substring(idx + italic!.length)),
        ],
      ),
    );
  }
}

/// Nút CTA gradient cam, full-width (vd "Try Demo", "Continue").
class IntroCtaButton extends StatelessWidget {
  const IntroCtaButton({
    super.key,
    required this.label,
    required this.onTap,
    this.sparkle = false,
  });

  final String label;
  final VoidCallback onTap;

  /// true: hiện icon ✦ phía sau; false: hiện chevron ›.
  final bool sparkle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: const LinearGradient(
            colors: [AppColors.ffA15600, AppColors.ffFF8C00],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ffFF8C00.withValues(alpha: 0.4),
              blurRadius: 22,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(16,
                      weight: FontWeight.w700, color: AppColors.ffFFFFFF)),
            ),
            SizedBox(width: 8.w),
            Icon(sparkle ? Icons.auto_awesome : Icons.chevron_right,
                color: AppColors.ffFFFFFF, size: sparkle ? 18.w : 22.w),
          ],
        ),
      ),
    );
  }
}

/// Pill nhấn nhỏ nền cam nhạt + icon ✦ + chữ cam đậm
/// (vd "Reading content", "2 hours saved", "+3 new spots").
class InfoPill extends StatelessWidget {
  const InfoPill(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.ffF7E2C0,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.ffC2691A, size: 13.w),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(13,
                    weight: FontWeight.w700, color: AppColors.ffC2691A)),
          ),
        ],
      ),
    );
  }
}

/// Quả cầu AI phát sáng cam (dùng ở "AI Magic", "AI Building").
class AiOrb extends StatelessWidget {
  const AiOrb({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppColors.ffFF8C00, AppColors.ffA15600],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ffFF8C00.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Icon(Icons.auto_awesome, color: AppColors.ffFFFFFF, size: s * 0.35),
    );
  }
}

/// Hộp "bản đồ" nền lưới nhạt, bo góc (dùng ở các màn có map/route).
/// [child] phủ lên trên (vd các pin, pill "Optimized route").
class GridMapBox extends StatelessWidget {
  const GridMapBox({super.key, this.height = 130, this.child});

  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.ffFFFFFF,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.ffE7DECF),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _GridPainter(),
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ffE7DECF.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pin định vị nhỏ màu cam (giọt nước) cho map.
class MapPin extends StatelessWidget {
  const MapPin({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.location_on, color: AppColors.ffC2691A, size: size.w);
  }
}
