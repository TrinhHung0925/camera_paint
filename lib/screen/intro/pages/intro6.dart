import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_resource.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 06 — WOW Result: header ảnh Tokyo + body kem cuộn (stats, map,
/// day-by-day) + CTA "Personalize My Trip" ghim đáy.
class Intro6 extends StatelessWidget {
  const Intro6({super.key, required this.controller});

  final IntroController controller;
  static const int pageIndex = 5;

  static const _stats = [
    ('4', 'DAYS', false),
    ('24', 'PLACES', false),
    ('9', 'CAFÉS', false),
    ('6', 'EATS', false),
    ('5', 'HIDDEN GEMS', false),
    ('98%', 'ROUTE SCORE', true),
  ];

  static const _days = [
    ('Day 1', 'Shibuya + Harajuku', '6 stops', Img.imgDestTokyo),
    ('Day 2', 'Tsukiji + Ginza', '7 stops', Img.imgFood),
    ('Day 3', 'Yanaka + Ueno', '6 stops', Img.imgDestKyoto),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: AppColors.ffF6EFE3,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _statsCard(),
                      SizedBox(height: 14.h),
                      Center(child: const InfoPill('2 hours saved vs planning yourself')),
                      SizedBox(height: 14.h),
                      _mapBox(),
                      SizedBox(height: 16.h),
                      const IntroEyebrow('DAY BY DAY', color: AppColors.ff9B948B),
                      SizedBox(height: 10.h),
                      _dayList(),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,


              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                child: IntroCtaButton(label: 'Personalize My Trip', onTap: controller.next),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER (đi dưới status bar, KHÔNG bọc SafeArea cho ảnh) ---
  Widget _header() {
    return SizedBox(
      height: 240.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Img.imgDestTokyo, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.ff0C0A07.withValues(alpha: 0.0), AppColors.ff0C0A07.withValues(alpha: 0.7)],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: TopBar(index: Intro6.pageIndex, pillText: 'Back', onPill: controller.back),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 18.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _readyPill(),
                SizedBox(height: 10.h),
                Text('JAPAN', style: AppText.eyebrow(AppColors.ffFF8C00)),
                SizedBox(height: 2.h),
                Text(
                  'Tokyo in 4 days',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.headline(30, weight: FontWeight.w600, color: AppColors.ffFFFFFF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readyPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.ff0C0A07.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.ffFF8C00, size: 13.w),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'Your demo trip is ready',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(12, weight: FontWeight.w600, color: AppColors.ffFFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  // --- STATS CARD (2 hàng x 3 ô) ---
  Widget _statsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: AppColors.ffEFE9DF, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in _stats.sublist(0, 3))
                Expanded(
                  child: _StatCell(value: s.$1, label: s.$2, accent: s.$3),
                ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in _stats.sublist(3, 6))
                Expanded(
                  child: _StatCell(value: s.$1, label: s.$2, accent: s.$3),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- MAP BOX với pin rải rác + pill "Optimized route" ---
  Widget _mapBox() {
    return GridMapBox(
      height: 120,
      child: Stack(
        children: [
          Positioned(left: 60.w, top: 26.h, child: const MapPin()),
          Positioned(left: 120.w, top: 14.h, child: const MapPin()),
          Positioned(left: 100.w, top: 52.h, child: const MapPin()),
          Positioned(left: 175.w, top: 36.h, child: const MapPin()),
          Positioned(left: 70.w, top: 68.h, child: const MapPin()),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(padding: EdgeInsets.all(10.w), child: const InfoPill('Optimized route')),
          ),
        ],
      ),
    );
  }

  // --- DAY BY DAY: list ngang 3 thẻ ---
  Widget _dayList() {
    return SizedBox(
      height: 126.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _days.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final d = _days[i];
          return _DayCard(day: d.$1, place: d.$2, stops: d.$3, image: d.$4);
        },
      ),
    );
  }
}

/// Ô thống kê: giá trị (serif) + label small-caps.
class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label, this.accent = false});

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.headline(22, weight: FontWeight.w600, color: accent ? AppColors.ffFF8C00 : AppColors.ff1A1714),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.eyebrow(AppColors.ff9B948B).copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }
}

/// Thẻ ngày: ảnh top (gradient + "Day N") + vùng trắng (địa điểm + số stops).
class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.place, required this.stops, required this.image});

  final String day;
  final String place;
  final String stops;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      decoration: BoxDecoration(color: AppColors.ffFFFFFF, borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 70.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(image, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.ff0C0A07.withValues(alpha: 0.0), AppColors.ff0C0A07.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
                Positioned(
                  left: 8.w,
                  bottom: 6.h,
                  right: 8.w,
                  child: Text(
                    day,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12, weight: FontWeight.w700, color: AppColors.ffFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12, weight: FontWeight.w600, color: AppColors.ff1A1714),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    stops,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(10, color: AppColors.ff7A736B),
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
