import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/reveal.dart';
import '../../resource/app_colors.dart';
import '../../resource/app_text.dart';
import 'splash_controller.dart';

/// Màn Splash tối giản — branding hiện ra từng cái, sau 5s tự động vào intro.
class SplashView extends StatefulWidget {
  SplashView({super.key}) {
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }
  }

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    Get.delete<SplashController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ff0C0A07,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Center(
              // Mỗi phần tử hiện ra lần lượt (icon -> tên -> tagline).
              child: RevealGroup(
                mainAxisSize: MainAxisSize.min,
                stagger: const Duration(milliseconds: 280),
                duration: const Duration(milliseconds: 560),
                children: [
                  _glowIcon(),
                  SizedBox(height: 14.h),
                  Text(
                    'Plan Trips',
                    style: AppText.headline(40,
                        weight: FontWeight.w600, color: AppColors.ffFFFFFF),
                  ),
                  Text('One perfect AI trip.',
                      style: AppText.headline(20,
                          italic: true, color: AppColors.ffFF8C00)),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 60.h,
              child: Center(
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                        AppColors.ffFFFFFF.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowIcon() {
    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.18).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.ffFF8C00.withValues(alpha: 0.45),
                    AppColors.ffFF8C00.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Icon(Icons.near_me, color: AppColors.ffFF8C00, size: 44.w),
        ],
      ),
    );
  }
}
