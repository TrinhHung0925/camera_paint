import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_resource.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 12 — Create Account: nền ảnh fade xuống nền kem, các nút đăng nhập.
class Intro12 extends StatelessWidget {
  const Intro12({super.key, required this.controller});

  final IntroController controller;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Img.imgDestTokyo, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.ffF6EFE3.withValues(alpha: 0.0),
                  AppColors.ffF6EFE3.withValues(alpha: 0.0),
                  AppColors.ffF6EFE3.withValues(alpha: 0.85),
                  AppColors.ffF6EFE3,
                ],
                stops: const [0.0, 0.40, 0.62, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: const IntroProgressBar(current: 11, onDark: true),
                  ),
                  const Spacer(),
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: AppColors.ffFF8C00,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.near_me,
                        color: AppColors.ffFFFFFF, size: 26.w),
                  ),
                  SizedBox(height: 16.h),
                  const IntroHeadline(
                    'Save your\npersonalized trip.',
                    italic: 'personalized trip.',
                    size: 30,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Your itinerary is ready. Create a free account so it never gets lost.',
                    style: AppText.body(14, color: AppColors.ff7A736B),
                  ),
                  SizedBox(height: 20.h),
                  _AuthButton(
                    label: 'Continue with Apple',
                    leading: Icon(Icons.apple,
                        color: AppColors.ffFFFFFF, size: 20.w),
                    bg: AppColors.ff1C1A17,
                    fg: AppColors.ffFFFFFF,
                    onTap: controller.next,
                  ),
                  SizedBox(height: 10.h),
                  _AuthButton(
                    label: 'Continue with Google',
                    leading: Text('G',
                        style: AppText.body(16,
                            weight: FontWeight.w700,
                            color: AppColors.ffFF8C00)),
                    bg: AppColors.ffFFFFFF,
                    fg: AppColors.ff1A1714,
                    border: AppColors.ffE7DECF,
                    onTap: controller.next,
                  ),
                  SizedBox(height: 10.h),
                  _AuthButton(
                    label: 'Continue with Email',
                    leading: Icon(Icons.mail_outline,
                        color: AppColors.ff1A1714, size: 20.w),
                    bg: AppColors.ffFFFFFF,
                    fg: AppColors.ff1A1714,
                    border: AppColors.ffE7DECF,
                    onTap: controller.next,
                  ),
                  SizedBox(height: 14.h),
                  Center(
                    child: GestureDetector(
                      onTap: controller.next,
                      child: Text('Maybe later',
                          style: AppText.body(14,
                              weight: FontWeight.w600,
                              color: AppColors.ff7A736B)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14.w,
                      runSpacing: 6.h,
                      children: const [
                        _TrustItem('No spam'),
                        _TrustItem('Private by default'),
                        _TrustItem('Delete anytime'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút đăng nhập full-width: leading (icon/text) + label, bo tròn.
class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    required this.leading,
    required this.bg,
    required this.fg,
    required this.onTap,
    this.border,
  });

  final String label;
  final Widget leading;
  final Color bg;
  final Color fg;
  final Color? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(26.r),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            SizedBox(width: 8.w),
            Text(label,
                style:
                    AppText.body(15, weight: FontWeight.w600, color: fg)),
          ],
        ),
      ),
    );
  }
}

/// Mục tin cậy nhỏ: ✓ + nhãn xám nhạt.
class _TrustItem extends StatelessWidget {
  const _TrustItem(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check, size: 12.w, color: AppColors.ff9B948B),
        SizedBox(width: 4.w),
        Text(label,
            style: AppText.body(11, color: AppColors.ff9B948B)),
      ],
    );
  }
}
