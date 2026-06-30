import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 02 — The Problem: so sánh "Today" lộn xộn vs "With Plan Trips".
class Intro2 extends StatelessWidget {
  const Intro2({super.key, required this.controller});

  final IntroController controller;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: RevealGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(index: 1, pillText: 'Back', onPill: controller.back),
            SizedBox(height: 22.h),
            const IntroEyebrow('THE PROBLEM'),
            SizedBox(height: 10.h),
            const IntroHeadline("Planning shouldn't\nfeel like a second job.", italic: 'second job.'),
            SizedBox(height: 12.h),
            Text(
              'Most travelers lose track of places before the\ntrip even begins.',
              style: AppText.body(15, color: AppColors.ff7A736B),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: _TodayCard()),

                  SizedBox(width: 12),
                  Expanded(child: _PlanCard()),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            IntroCtaButton(label: 'Show Me', onTap: controller.next),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard();

  static const _chips = [
    ('12 browser tabs', -0.02),
    ('Screenshots', 0.03),
    ('Google Maps', -0.015),
    ('Notes app', 0.02),
    ('Bookmarks', -0.01),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(

      height: 330.h,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.ffFDFBF7,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.ff000000.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const IntroEyebrow('TODAY', color: AppColors.ff9B948B),
          SizedBox(height: 14.h),
          for (int i = 0; i < _chips.length; i++) ...[
            if (i != 0) SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Transform.rotate(
                  angle: _chips[i].$2, child: _chip(_chips[i].$1)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.ffFFFFFF,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(color: AppColors.ff000000.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.body(12.5, weight: FontWeight.w500, color: AppColors.ff1A1714),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard();

  static const _days = [
    ('🏙️', 'Day 1', 'Shibuya + Harajuku'),
    ('🍣', 'Day 2', 'Tsukiji + Ginza'),
    ('⛩️', 'Day 3', 'Yanaka + Ueno'),
    ('🎨', 'Day 4', 'Odaiba + teamLab'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330.h,
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
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.near_me, color: AppColors.ffC2691A, size: 14.w),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  'Tokyo · 4 days',
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(14, weight: FontWeight.w700, color: AppColors.ff1A1714),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          for (int i = 0; i < _days.length; i++) ...[
            if (i != 0) SizedBox(height: 8.h),
            _dayTile(_days[i].$1, _days[i].$2, _days[i].$3),
          ],
        ],
      ),
    );
  }

  Widget _dayTile(String emoji, String day, String places) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(color: AppColors.ffFFFFFF, borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: AppText.body(12, weight: FontWeight.w700, color: AppColors.ff1A1714),
                ),
                Text(
                  places,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(11, color: AppColors.ff7A736B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
