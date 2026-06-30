import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/crossfade_background.dart';
import '../../../resource/app_colors.dart';
import '../../../resource/app_resource.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 01 — Cinematic Hook: nền ảnh Tokyo, headline, CTA "Start Planning".
class Intro1 extends StatelessWidget {
  const Intro1({super.key, required this.controller});

  final IntroController controller;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CrossfadeBackground(
            images: [
              Img.imgOnboardingTokyo,
              Img.imgDestTokyo,
              Img.imgTokyoTower,
              Img.imgDestKyoto,
              Img.imgFuji,
              Img.imgDestParis,
            ],
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.ff0C0A07.withValues(alpha: 0.35),
                  AppColors.ff0C0A07.withValues(alpha: 0.0),
                  AppColors.ff0C0A07.withValues(alpha: 0.55),
                  AppColors.ff0C0A07,
                ],
                stops: const [0.0, 0.28, 0.62, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: RevealGroup(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TopBar(
                    index: 0,
                    pillText: 'Skip',
                    onPill: controller.skip,
                    onDark: true,
                  ),
                  SizedBox(height: 28.h),
                  Center(child: const _TokyoCard()),
                  const Spacer(),
                  Text('All your travel\ninspiration.',
                      style: AppText.headline(34,
                          weight: FontWeight.w500, color: AppColors.ffFFFFFF)),
                  Text('One perfect AI trip.',
                      style: AppText.headline(34,
                          weight: FontWeight.w500,
                          italic: true,
                          color: AppColors.ffFF8C00)),
                  SizedBox(height: 12.h),
                  Text(
                    'Turn scattered ideas into a beautiful travel\nplan in seconds.',
                    style: AppText.body(15,
                        color: AppColors.ffFFFFFF.withValues(alpha: 0.8)),
                  ),
                  SizedBox(height: 22.h),
                  IntroCtaButton(
                      label: 'Start Planning', onTap: controller.next),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TokyoCard extends StatelessWidget {
  const _TokyoCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 170.w,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.ff000000.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16.r),
            border:
                Border.all(color: AppColors.ffFFFFFF.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.near_me, color: AppColors.ffFF8C00, size: 15.w),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text('Tokyo · 4 days',
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(13,
                            weight: FontWeight.w700,
                            color: AppColors.ffFFFFFF)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _line(0.9),
              SizedBox(height: 7.h),
              _line(0.6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(double widthFactor) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: 5.h,
        decoration: BoxDecoration(
          color: AppColors.ffFFFFFF.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(3.r),
        ),
      ),
    );
  }
}
