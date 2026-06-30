import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../../../resource/app_resource.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 04 — Interactive Demo: chọn 1 điểm đến để AI dựng lịch trình demo.
class Intro4 extends StatelessWidget {
  const Intro4({super.key, required this.controller});

  final IntroController controller;

  static const _dests = <_DestData>[
    _DestData(
      name: 'Tokyo',
      country: 'Japan',
      badge: 'MOST LOVED',
      tag: 'Food & neon',
      meta: '4 days · 24 spots · 18°',
      image: Img.imgDestTokyo,
      selected: true,
    ),
    _DestData(
      name: 'Bali',
      country: 'Indonesia',
      badge: 'TRENDING',
      tag: 'Beaches & temples',
      meta: '6 days · 19 spots · 30°',
      image: Img.imgDestBali,
    ),
    _DestData(
      name: 'Paris',
      country: 'France',
      badge: 'CLASSIC',
      tag: 'Cafés & art',
      meta: '5 days · 22 spots · 14°',
      image: Img.imgDestParis,
    ),
    _DestData(
      name: 'New York',
      country: 'USA',
      badge: 'POPULAR',
      tag: 'City & food',
      meta: '4 days · 26 spots · 11°',
      image: Img.imgDestNewyork,
    ),
    _DestData(
      name: 'Iceland',
      country: 'Reykjavik',
      badge: 'ADVENTURE',
      tag: 'Nature & roads',
      meta: '7 days · 17 spots · 4°',
      image: Img.imgDestIceland,
    ),
    _DestData(
      name: 'Kyoto',
      country: 'Japan',
      badge: 'SERENE',
      tag: 'Temples & gardens',
      meta: '3 days · 20 spots · 16°',
      image: Img.imgDestKyoto,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: RevealGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(index: 3, pillText: 'Back', onPill: controller.back),
            SizedBox(height: 22.h),
            const IntroEyebrow('INTERACTIVE DEMO'),
            SizedBox(height: 10.h),
            const IntroHeadline("Pick a place.\nWe'll build it live.",
                italic: 'build it live.'),
            SizedBox(height: 18.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.74,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final d in _dests) _DestCard(data: d),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            IntroCtaButton(
              label: 'Generate My Demo Trip',
              onTap: controller.next,
              sparkle: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dữ liệu 1 thẻ điểm đến.
class _DestData {
  const _DestData({
    required this.name,
    required this.country,
    required this.badge,
    required this.tag,
    required this.meta,
    required this.image,
    this.selected = false,
  });

  final String name;
  final String country;
  final String badge;
  final String tag;
  final String meta;
  final String image;
  final bool selected;
}

/// Thẻ điểm đến: ảnh + gradient phủ + badge + tên/quốc gia, dưới là tag + meta.
class _DestCard extends StatelessWidget {
  const _DestCard({required this.data});

  final _DestData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ffFDFBF7,
        borderRadius: BorderRadius.circular(16.r),
        border: data.selected
            ? Border.all(color: AppColors.ffFF8C00, width: 2)
            : Border.all(color: AppColors.ffEFE9DF),
        boxShadow: [
          BoxShadow(
            color: AppColors.ff0C0A07.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh + lớp phủ + badge + tên.
          SizedBox(
            height: 95.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(data.image, fit: BoxFit.cover),
                // Gradient tối ở đáy ảnh để chữ trắng nổi rõ.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.ff0C0A07.withValues(alpha: 0.0),
                        AppColors.overlayDim,
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                // Badge pill góc trên-trái.
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.ff0C0A07.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      data.badge,
                      style: AppText.body(8.5,
                          weight: FontWeight.w700,
                          color: AppColors.ffFFFFFF,
                          letterSpacing: 0.6),
                    ),
                  ),
                ),
                // Check tròn cam góc trên-phải khi được chọn.
                if (data.selected)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: const BoxDecoration(
                        color: AppColors.ffFF8C00,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check,
                          color: AppColors.ffFFFFFF, size: 14.w),
                    ),
                  ),
                // Tên + quốc gia ở đáy ảnh.
                Positioned(
                  left: 10.w,
                  right: 10.w,
                  bottom: 8.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.headline(17,
                            weight: FontWeight.w600,
                            color: AppColors.ffFFFFFF),
                      ),
                      Text(
                        data.country,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(10,
                            color: AppColors.ffFFFFFF, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Vùng trắng dưới: tag (cam) + meta.
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12,
                        weight: FontWeight.w600, color: AppColors.ffC2691A),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    data.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(11, color: AppColors.ff7A736B),
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
