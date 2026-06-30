import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 03 — AI Magic: AI tự đọc nội dung từ nhiều nguồn và sắp xếp giúp bạn.
class Intro3 extends StatelessWidget {
  const Intro3({super.key, required this.controller});

  final IntroController controller;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: RevealGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(index: 2, pillText: 'Back', onPill: controller.back),
            SizedBox(height: 22.h),
            const IntroEyebrow('HOW IT WORKS'),
            SizedBox(height: 10.h),
            const IntroHeadline('Watch AI\norganize everything.',
                italic: 'everything.'),
            SizedBox(height: 22.h),
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SourceChip(icon: Icons.music_note, label: 'TikTok'),
                  SizedBox(width: 12),
                  _SourceChip(icon: Icons.camera_alt, label: 'Instagram'),
                  SizedBox(width: 12),
                  _SourceChip(icon: Icons.location_on, label: 'Google Maps'),
                  SizedBox(width: 12),
                  _SourceChip(icon: Icons.photo_camera, label: 'Screenshot'),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Center(
              child: Container(
                width: 2.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.ffFF8C00,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            const Center(child: AiOrb(size: 64)),
            SizedBox(height: 18.h),
            GridMapBox(
              height: 150,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: const InfoPill('Reading content'),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Text(
                'No copy & paste. No spreadsheets. No manual planning.',
                textAlign: TextAlign.center,
                style: AppText.body(14, color: AppColors.ff7A736B),
              ),
            ),
            const Spacer(),
            IntroCtaButton(
                label: 'Try Demo', onTap: controller.next, sparkle: true),
          ],
        ),
      ),
    );
  }
}

/// Chip nguồn: ô vuông trắng bo góc chứa icon + nhãn nhỏ bên dưới.
class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: AppColors.ffFFFFFF,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.ff000000.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.ff1A1714, size: 22.w),
        ),
        SizedBox(height: 6.h),
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.body(11, color: AppColors.ff7A736B),
          ),
        ),
      ],
    );
  }
}
