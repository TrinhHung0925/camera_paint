import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 13 — Premium: paywall mềm với free trial, danh sách tính năng và CTA.
class Intro13 extends StatelessWidget {
  const Intro13({super.key, required this.controller});

  final IntroController controller;

  static const _leftFeatures = [
    'Personalized itinerary',
    'Unlimited saved places',
    'Offline access',
    'Daily planner',
  ];

  static const _rightFeatures = [
    'AI route optimization',
    'Hidden gems',
    'Smart packing',
    'Unlimited trips',
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: RevealGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 'Not now' advances to finish onboarding.
            TopBar(index: 12, pillText: 'Not now', onPill: controller.next),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: AppColors.ffF7E2C0,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: AppColors.ffC2691A, size: 13.w),
                            SizedBox(width: 6.w),
                            Text('7-day free trial',
                                style: AppText.body(12,
                                    weight: FontWeight.w700,
                                    color: AppColors.ffC2691A)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text.rich(
                      TextSpan(
                        style: AppText.headline(28,
                            weight: FontWeight.w600,
                            color: AppColors.ff1A1714),
                        children: const [
                          TextSpan(text: 'Your AI trip is '),
                          TextSpan(
                            text: 'waiting.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.ffFF8C00,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Unlock the full, personalized itinerary you just built.',
                      style:
                          AppText.body(14, color: AppColors.ff7A736B),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.ffEFE9DF,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final f in _leftFeatures) ...[
                                  _Feature(label: f),
                                  SizedBox(height: 12.h),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final f in _rightFeatures) ...[
                                  _Feature(label: f),
                                  SizedBox(height: 12.h),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 44.w,
                            height: 20.w,
                            child: Stack(
                              children: [
                                _avatar(AppColors.ffFF8C00, 0),
                                _avatar(AppColors.ffC2691A, 12.w),
                                _avatar(AppColors.ffF8CD97, 24.w),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'Trusted by thousands of travelers',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(12,
                                  color: AppColors.ff7A736B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < 5; i++)
                            Icon(Icons.star,
                                color: AppColors.ffFF8C00, size: 14.w),
                          SizedBox(width: 6.w),
                          Text('4.9',
                              style: AppText.body(13,
                                  weight: FontWeight.w700,
                                  color: AppColors.ff1A1714)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Then \$6.99/mo · Cancel anytime',
                textAlign: TextAlign.center,
                style: AppText.body(12, color: AppColors.ff7A736B),
              ),
            ),
            SizedBox(height: 10.h),
            IntroCtaButton(
              label: 'Unlock My Trip',
              onTap: controller.next,
              sparkle: true,
            ),
            SizedBox(height: 10.h),
            Center(
              child: GestureDetector(
                onTap: controller.next,
                child: Text(
                  'Continue free',
                  style: AppText.body(14,
                      weight: FontWeight.w600, color: AppColors.ff7A736B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(Color color, double left) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 10.w,
        backgroundColor: AppColors.ffFFFFFF,
        child: CircleAvatar(radius: 8.5.w, backgroundColor: color),
      ),
    );
  }
}

/// Một dòng tính năng: chấm cam có dấu tick + nhãn.
class _Feature extends StatelessWidget {
  const _Feature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ffFF8C00,
          ),
          child: Icon(Icons.check, color: AppColors.ffFFFFFF, size: 12.w),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(12.5,
                weight: FontWeight.w500, color: AppColors.ff1A1714),
          ),
        ),
      ],
    );
  }
}
