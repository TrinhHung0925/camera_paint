import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_resource.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 08 — Live Upgrade: trip vừa được "tinh chỉnh" theo loại traveler đã
/// chọn ở intro7; các mục thêm vào (+N) chạy ra tuần tự khi tới trang.
class Intro8 extends StatefulWidget {
  const Intro8({super.key, required this.controller});

  final IntroController controller;

  static const int pageIndex = 7;

  @override
  State<Intro8> createState() => _Intro8State();
}

class _Intro8State extends State<Intro8> with SingleTickerProviderStateMixin {
  /// Các mục được thêm theo từng loại traveler.
  static const _byType = <String, List<(String, String)>>{
    'Food Explorer': [
      ('+6', 'ramen spots'),
      ('+4', 'street food stalls'),
      ('+3', 'local cafés'),
    ],
    'Hidden Gem Hunter': [
      ('+5', 'secret spots'),
      ('+3', 'backstreets'),
      ('+2', 'local-only stops'),
    ],
    'Adventure Seeker': [
      ('+4', 'hikes & trails'),
      ('+3', 'viewpoints'),
      ('+2', 'day trips'),
    ],
    'Luxury Traveler': [
      ('+3', 'fine dining'),
      ('+2', 'spas'),
      ('+2', 'rooftop bars'),
    ],
    'Family Traveler': [
      ('+4', 'kid-friendly spots'),
      ('+3', 'parks'),
      ('+2', 'museums'),
    ],
    'Culture Lover': [
      ('+6', 'temples & shrines'),
      ('+3', 'museums'),
      ('+2', 'craft workshops'),
    ],
    'Nightlife Explorer': [
      ('+5', 'bars'),
      ('+3', 'clubs'),
      ('+2', 'live music'),
    ],
    'Budget Traveler': [
      ('+6', 'free spots'),
      ('+4', 'cheap eats'),
      ('+3', 'local deals'),
    ],
  };

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _started = false;

  IntroController get controller => widget.controller;

  List<(String, String)> get _items =>
      _byType[controller.travelerType] ?? _byType['Food Explorer']!;

  @override
  void initState() {
    super.initState();
    controller.pageController.addListener(_maybeStart);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  void _maybeStart() {
    if (_started || !mounted) return;
    final pc = controller.pageController;
    if (!pc.hasClients || pc.positions.isEmpty) return;
    if ((pc.page ?? 0).round() == Intro8.pageIndex) {
      setState(() => _started = true); // đọc lại traveler mới nhất
      _c.forward();
    }
  }

  @override
  void dispose() {
    controller.pageController.removeListener(_maybeStart);
    _c.dispose();
    super.dispose();
  }

  Animation<double> _itemAnim(int i) {
    final total = _c.duration!.inMilliseconds;
    final start = (200 * i) / total;
    final end = (200 * i + 520) / total;
    return CurvedAnimation(
      parent: _c,
      curve:
          Interval(start.clamp(0, 1), end.clamp(0, 1), curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = controller.travelerType;
    final items = _items;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
                index: Intro8.pageIndex,
                pillText: 'Back',
                onPill: controller.back),
            SizedBox(height: 22.h),
            const IntroEyebrow('UPDATING LIVE'),
            SizedBox(height: 10.h),
            const IntroHeadline('Your trip just\nbecame smarter.',
                italic: 'smarter.'),
            SizedBox(height: 12.h),
            Text.rich(
              TextSpan(
                style: AppText.body(15, color: AppColors.ff7A736B),
                children: [
                  const TextSpan(text: 'Tuned for '),
                  TextSpan(
                    text: '${type.toLowerCase()}s',
                    style: AppText.body(15,
                        weight: FontWeight.w700, color: AppColors.ff1A1714),
                  ),
                  const TextSpan(text: " — here's what we added."),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            _UpgradeCard(emoji: controller.travelerEmoji, type: type),
            SizedBox(height: 14.h),
            for (int i = 0; i < items.length; i++) ...[
              if (i != 0) SizedBox(height: 10.h),
              RevealItem(
                animation: _itemAnim(i),
                child: _AddedRow(count: items[i].$1, label: items[i].$2),
              ),
            ],
            const Spacer(),
            IntroCtaButton(label: 'Continue', onTap: controller.next),
          ],
        ),
      ),
    );
  }
}

/// Dòng "vừa thêm": +N (cam, đậm) · nhãn · dấu check cam.
class _AddedRow extends StatelessWidget {
  const _AddedRow({required this.count, required this.label});

  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.ffF8E8D0,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38.w,
            child: Text(
              count,
              style: AppText.body(18,
                  weight: FontWeight.w700, color: AppColors.ffFF8C00),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(14,
                  weight: FontWeight.w600, color: AppColors.ff1A1714),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.check, size: 18.w, color: AppColors.ffC2691A),
        ],
      ),
    );
  }
}

/// Thẻ ảnh bo góc + gradient tối + nhãn "Refreshed for you" / loại traveler.
class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.emoji, required this.type});

  final String emoji;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.h,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ff0C0A07.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Img.imgTokyoTower, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.ff0C0A07.withValues(alpha: 0.0),
                  AppColors.ff0C0A07.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.ffFFFFFF,
                        shape: BoxShape.circle,
                      ),
                      child: Text(emoji, style: TextStyle(fontSize: 11.sp)),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text('Refreshed for you',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.headline(16,
                              weight: FontWeight.w500,
                              color: AppColors.ffFFFFFF)),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(type,
                    style: AppText.body(11,
                        color: AppColors.ffFFFFFF.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
