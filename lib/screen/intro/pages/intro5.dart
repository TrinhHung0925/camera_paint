import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../resource/app_colors.dart';
import '../../../resource/app_text.dart';
import '../intro_controller.dart';
import '../widgets/intro_widgets.dart';

/// Trang 05 — AI Building: màn "đang dựng lịch trình".
///
/// Chạy động: các bước tick lần lượt, progress chạy lên 100%, xong tự sang
/// màn kết quả. Chỉ bắt đầu khi người dùng thực sự tới trang này (lắng nghe
/// PageController) để không chạy sớm lúc PageView preload trang kề.
class Intro5 extends StatefulWidget {
  const Intro5({super.key, required this.controller});

  final IntroController controller;

  static const int pageIndex = 4;

  @override
  State<Intro5> createState() => _Intro5State();
}

class _Intro5State extends State<Intro5> with TickerProviderStateMixin {
  static const _steps = [
    'Reading your travel content',
    'Extracting locations',
    'Finding hidden gems',
    'Checking opening hours',
    'Optimizing the route',
    'Balancing each day',
    'Creating your itinerary',
  ];

  static const _totalSeconds = 6;

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalSeconds * 1000),
  )..addStatusListener(_onStatus);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  bool _started = false;
  bool _advanced = false;

  IntroController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.pageController.addListener(_maybeStart);
    // Trường hợp đã ở sẵn trang này khi build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  void _maybeStart() {
    if (_started || !mounted) return;
    final pc = c.pageController;
    if (!pc.hasClients || pc.positions.isEmpty) return;
    if ((pc.page ?? 0).round() == Intro5.pageIndex) {
      _started = true;
      _progress.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _advanced || !mounted) return;
    final pc = c.pageController;
    if (pc.hasClients && (pc.page ?? 0).round() == Intro5.pageIndex) {
      _advanced = true;
      c.next();
    }
  }

  @override
  void dispose() {
    c.pageController.removeListener(_maybeStart);
    _progress.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: IntroScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(index: Intro5.pageIndex, pillText: 'Back', onPill: c.back),
            SizedBox(height: 24.h),
            Center(
              child: ScaleTransition(
                scale: Tween(begin: 0.94, end: 1.06).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: const AiOrb(size: 88),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: Center(
                child: Text('Building Tokyo',
                    textAlign: TextAlign.center,
                    style: AppText.headline(24, weight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              width: double.infinity,
              child: Center(
                child: Text("Building something you'll actually enjoy.",
                    textAlign: TextAlign.center,
                    style: AppText.body(14, color: AppColors.ff7A736B)),
              ),
            ),
            SizedBox(height: 24.h),
            // Checklist + progress chạy theo _progress.
            AnimatedBuilder(
              animation: _progress,
              builder: (context, _) {
                final p = _progress.value;
                final completed = (p * _steps.length).floor();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _steps.length; i++) ...[
                      _ChecklistRow(
                        label: _steps[i],
                        state: i < completed
                            ? _StepState.done
                            : (i == completed
                                ? _StepState.active
                                : _StepState.pending),
                      ),
                      if (i != _steps.length - 1) SizedBox(height: 16.h),
                    ],
                  ],
                );
              },
            ),
            const Spacer(),
            // Vùng progress — chạm để bỏ qua chờ.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: c.next,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  final p = _progress.value;
                  final percent = (p * 100).round();
                  final secLeft = ((1 - p) * _totalSeconds).ceil();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('$percent%',
                              style: AppText.body(13,
                                  weight: FontWeight.w700,
                                  color: AppColors.ff1A1714)),
                          const Spacer(),
                          Text(percent >= 100 ? 'Done' : '~${secLeft}s left',
                              style: AppText.body(13,
                                  color: AppColors.ff7A736B)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3.r),
                        child: Container(
                          height: 6.h,
                          width: double.infinity,
                          color: AppColors.ffEFE9DF,
                          child: FractionallySizedBox(
                            widthFactor: p.clamp(0.0, 1.0),
                            alignment: Alignment.centerLeft,
                            child: Container(color: AppColors.ffFF8C00),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, active, pending }

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.label, required this.state});

  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    final Color labelColor;
    final FontWeight labelWeight;

    switch (state) {
      case _StepState.done:
        icon = Icons.check_circle;
        iconColor = AppColors.ffFF8C00;
        labelColor = AppColors.ff1A1714;
        labelWeight = FontWeight.w600;
      case _StepState.active:
        icon = Icons.radio_button_checked;
        iconColor = AppColors.ffFF8C00;
        labelColor = AppColors.ff1A1714;
        labelWeight = FontWeight.w600;
      case _StepState.pending:
        icon = Icons.radio_button_unchecked;
        iconColor = AppColors.ff9B948B;
        labelColor = AppColors.ff9B948B;
        labelWeight = FontWeight.w400;
    }

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(15, weight: labelWeight, color: labelColor)),
        ),
      ],
    );
  }
}
