import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 09 — Discovery Sources: chọn (nhiều) nguồn tìm ý tưởng du lịch.
class Intro9 extends StatefulWidget {
  const Intro9({super.key, required this.controller});

  final IntroController controller;

  @override
  State<Intro9> createState() => _Intro9State();
}

class _Intro9State extends State<Intro9> {
  static const _sources = <(IconData, String)>[
    (Icons.music_note, 'TikTok'),
    (Icons.camera_alt, 'Instagram'),
    (Icons.location_on, 'Google Maps'),
    (Icons.favorite_border, 'Pinterest'),
    (Icons.play_circle_outline, 'YouTube'),
    (Icons.link, 'Blogs'),
    (Icons.people_outline, 'Friends'),
    (Icons.photo_camera, 'Screenshots'),
    (Icons.forum_outlined, 'Reddit'),
  ];

  /// Tập các nguồn đã chọn (mặc định 3 đầu như design).
  final Set<int> _selected = {0, 1, 2};

  void _toggle(int i) {
    setState(() {
      if (!_selected.add(i)) _selected.remove(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: RevealGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(index: 8, pillText: 'Back', onPill: controller.back),
            SizedBox(height: 22.h),
            const IntroEyebrow('PERSONALIZE · 2 OF 2'),
            SizedBox(height: 10.h),
            const IntroHeadline('Where do you\nfind travel ideas?',
                italic: 'travel ideas?'),
            SizedBox(height: 10.h),
            Text(
              'Pick all that apply — it tunes your recommendations.',
              style: AppText.body(15, color: AppColors.ff7A736B),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.95,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < _sources.length; i++)
                    _SourceCard(
                      icon: _sources[i].$1,
                      label: _sources[i].$2,
                      selected: _selected.contains(i),
                      onTap: () => _toggle(i),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            IntroCtaButton(label: 'Continue', onTap: controller.next),
          ],
        ),
      ),
    );
  }
}

/// Thẻ nguồn khám phá: icon trong ô vuông trắng + nhãn bên dưới, bấm để toggle.
class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? AppColors.ffFBEAD0 : AppColors.ffEFE9DF,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.ffFF8C00 : AppColors.ffEFE9DF,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.ffFF8C00.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.ffFFFFFF,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: AppColors.ff1A1714, size: 20.w),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppText.body(
                      12,
                      weight: selected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          selected ? AppColors.ff1A1714 : AppColors.ff7A736B,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 8.w,
                right: 8.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.ffFF8C00,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
