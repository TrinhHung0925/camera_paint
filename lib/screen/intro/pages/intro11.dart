import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 11 — Your Travel Forecast: so sánh "Without" vs "With Plan Trips".
class Intro11 extends StatelessWidget {
  const Intro11({super.key, required this.controller});

  final IntroController controller;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: RevealGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(index: 10, pillText: 'Back', onPill: controller.back),
            SizedBox(height: 22.h),
            const IntroEyebrow('YOUR TRAVEL FORECAST'),
            SizedBox(height: 10.h),
            const IntroHeadline("Here's how much\neasier travel becomes.",
                italic: 'becomes.'),
            SizedBox(height: 24.h),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(child: _WithoutCard()),
                  SizedBox(width: 12),
                  Expanded(child: _WithCard()),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: const InfoPill('Most travelers save ~2 hours per trip day'),
            ),
            const Spacer(),
            IntroCtaButton(label: 'Create My Trip', onTap: controller.next),
          ],
        ),
      ),
    );
  }
}

class _WithoutCard extends StatelessWidget {
  const _WithoutCard();

  static const _items = [
    '12 browser tabs',
    '18 screenshots',
    '3 separate maps',
    'Random notes',
    'Messy, stressful planning',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.ffEFE9DF,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IntroEyebrow('WITHOUT PLAN TRIPS', color: AppColors.ff9B948B),
          SizedBox(height: 14.h),
          for (final item in _items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.close, size: 16.w, color: AppColors.ff9B948B),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(item,
                      style: AppText.body(13, color: AppColors.ff7A736B)),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _WithCard extends StatelessWidget {
  const _WithCard();

  static const _items = [
    'One clean itinerary',
    'One smart map',
    'Organized days',
    'Optimized routes',
    'Offline access',
    'AI recommendations',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.ffFBEAD0,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.ffF8CD97),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IntroEyebrow('WITH PLAN TRIPS'),
          SizedBox(height: 14.h),
          for (final item in _items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check, size: 16.w, color: AppColors.ffC2691A),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(item,
                      style: AppText.body(13,
                          weight: FontWeight.w600, color: AppColors.ff1A1714)),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}
