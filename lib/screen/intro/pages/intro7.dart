import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 07 — Traveler Type: chọn 1 trong 8 loại du khách (lưới 2 cột).
class Intro7 extends StatefulWidget {
  const Intro7({super.key, required this.controller});

  final IntroController controller;

  @override
  State<Intro7> createState() => _Intro7State();
}

class _Intro7State extends State<Intro7> {
  static const _options = [

    
    ('🍜', 'Food Explorer'),
    ('💎', 'Hidden Gem Hunter'),
    ('⛰️', 'Adventure Seeker'),
    ('🥂', 'Luxury Traveler'),
    ('🧸', 'Family Traveler'),
    ('⛩️', 'Culture Lover'),
    ('🌃', 'Nightlife Explorer'),
    ('🎒', 'Budget Traveler'),
  ];

  /// Lựa chọn hiện tại (mặc định Food Explorer).
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: RevealGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(index: 6, pillText: 'Back', onPill: controller.back),
            SizedBox(height: 22.h),
            const IntroEyebrow('PERSONALIZE · 1 OF 2'),
            SizedBox(height: 10.h),
            const IntroHeadline('What kind of\ntraveler are you?',
                italic: 'are you?'),
            SizedBox(height: 22.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1.7,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < _options.length; i++)
                    _OptionCard(
                      emoji: _options[i].$1,
                      label: _options[i].$2,
                      selected: i == _selected,
                      onTap: () {
                        setState(() => _selected = i);
                        controller.setTraveler(
                            _options[i].$2, _options[i].$1);
                      },
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.ffFBEAD0 : AppColors.ffEFE9DF,
          borderRadius: BorderRadius.circular(14.r),
          border: selected
              ? Border.all(color: AppColors.ffFF8C00, width: 2)
              : Border.all(color: AppColors.ffEFE9DF, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.ffFF8C00.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: TextStyle(fontSize: 22.sp)),
                SizedBox(height: 8.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(14,
                      weight: FontWeight.w600, color: AppColors.ff1A1714),
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.ffFF8C00,
                  ),
                  child:
                      Icon(Icons.check, color: AppColors.ffFFFFFF, size: 15.w),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
