import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 10 — Second Pass: AI tiếp tục cải thiện chuyến đi (thêm spot/hidden gems).
class Intro10 extends StatelessWidget {
  const Intro10({super.key, required this.controller});

  final IntroController controller;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: RevealGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(index: 9, pillText: 'Back', onPill: controller.back),
            SizedBox(height: 22.h),
            const IntroEyebrow('SECOND PASS'),
            SizedBox(height: 10.h),
            const IntroHeadline('AI keeps improving\nyour trip.',
                italic: 'your trip.'),
            SizedBox(height: 20.h),
            GridMapBox(
              height: 120,
              child: Stack(
                children: [
                  Positioned(left: 70.w, top: 30.h, child: const MapPin()),
                  Positioned(left: 150.w, top: 16.h, child: const MapPin()),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: const InfoPill('+3 new spots'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            const _GemCard(),
            const Spacer(),
            Center(
              child: Text(
                'The more we know, the better your itinerary becomes.',
                textAlign: TextAlign.center,
                style: AppText.body(14, color: AppColors.ff7A736B),
              ),
            ),
            SizedBox(height: 16.h),
            IntroCtaButton(label: 'Almost Done', onTap: controller.next),
          ],
        ),
      ),
    );
  }
}

class _GemCard extends StatelessWidget {
  const _GemCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.ffEFE9DF,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ffFBEAD0,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text('💎', style: TextStyle(fontSize: 18.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('8 more hidden gems added',
                    style: AppText.body(14,
                        weight: FontWeight.w700, color: AppColors.ff1A1714)),
                Text('Backstreets & local-only spots',
                    style: AppText.body(12, color: AppColors.ff7A736B)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
