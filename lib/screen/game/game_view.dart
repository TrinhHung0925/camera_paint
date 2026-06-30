import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../resource/app_colors.dart';
import '../../resource/app_text.dart';
import 'game_controller.dart';

/// Màn game "chém hoa quả trên không": đếm ngược 3-2-1 rồi chơi 60s,
/// chém bằng cách quẹt tay (1 ngón hay cả bàn) qua quả.
class GameView extends StatefulWidget {
  GameView({super.key}) {
    if (!Get.isRegistered<GameController>()) {
      Get.put(GameController());
    }
  }

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<GameController>();
  late final _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (controller.isReady) controller.onTick(dt.clamp(0.0, 0.05));
  }

  @override
  void dispose() {
    _ticker.dispose();
    Get.delete<GameController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ff000000,
      body: GetBuilder<GameController>(
        builder: (c) {
          if (c.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(c.errorMessage!,
                    textAlign: TextAlign.center,
                    style:
                        AppText.body(15, color: AppColors.ffFFFFFF)),
              ),
            );
          }
          if (!c.isReady || c.camera == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.ffFFFFFF),
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              _CameraCover(camera: c.camera!),
              // Lớp game + HUD, cập nhật mỗi frame theo repaintTick.
              ValueListenableBuilder<int>(
                valueListenable: c.repaintTick,
                builder: (context, _, _) => Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _GamePainter(c))),
                    _Hud(c: c),
                    if (c.phase == GamePhase.countdown) _CountdownOverlay(c: c),
                    if (c.levelBannerT > 0 && c.phase == GamePhase.playing)
                      _LevelBanner(level: c.level),
                    if (c.phase == GamePhase.gameOver) _GameOverOverlay(c: c),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ===================== HUD =====================

class _Hud extends StatelessWidget {
  const _Hud({required this.c});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final s = c.timeLeftSec;
    final time = '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Column(
          children: [
            Row(
              children: [
                _circleBtn(Icons.arrow_back, c.onBack),
                const Spacer(),
                _pill('🍉 ${c.score}'),
                SizedBox(width: 8.w),
                _pill('⏱ $time'),
              ],
            ),
            SizedBox(height: 8.h),
            // Thanh thời gian.
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: (c.timeLeft / GameController.gameDuration).clamp(0.0, 1.0),
                minHeight: 6.h,
                backgroundColor: AppColors.ffFFFFFF.withValues(alpha: 0.2),
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.ffFF8C00),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _pill('Lv ${c.level}'),
                const Spacer(),
                Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Icon(
                        i < c.lives ? Icons.favorite : Icons.favorite_border,
                        color: i < c.lives
                            ? AppColors.ffE53935
                            : AppColors.ffFFFFFF.withValues(alpha: 0.4),
                        size: 22.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.overlayDim,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(text,
            style: AppText.body(15,
                weight: FontWeight.w700, color: AppColors.ffFFFFFF)),
      );

  Widget _circleBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: const BoxDecoration(
            color: AppColors.overlayDim,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.ffFFFFFF, size: 22.w),
        ),
      );
}

// ===================== Overlays =====================

class _CountdownOverlay extends StatelessWidget {
  const _CountdownOverlay({required this.c});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ff000000.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${c.countdown}',
              style: AppText.headline(96,
                  weight: FontWeight.w700, color: AppColors.ffFFFFFF)),
          Text('Sẵn sàng chém!',
              style: AppText.body(16, color: AppColors.ffFFFFFF)),
        ],
      ),
    );
  }
}

class _LevelBanner extends StatelessWidget {
  const _LevelBanner({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.ffFF8C00.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text('LEVEL $level',
              style: AppText.headline(28,
                  weight: FontWeight.w700, color: AppColors.ffFFFFFF)),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({required this.c});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ff000000.withValues(alpha: 0.7),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(c.timeLeft <= 0 ? 'Hết giờ!' : 'Game Over',
              style: AppText.headline(40,
                  weight: FontWeight.w700, color: AppColors.ffFFFFFF)),
          SizedBox(height: 12.h),
          Text('Điểm: ${c.score}   •   Level ${c.level}',
              style: AppText.body(16, color: AppColors.ffFFFFFF)),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: c.restart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ffFF8C00,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
            ),
            child: Text('Chơi lại',
                style: AppText.body(16,
                    weight: FontWeight.w700, color: AppColors.ffFFFFFF)),
          ),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: c.onBack,
            child: Text('Về trang chủ',
                style: AppText.body(15, color: AppColors.ffFFFFFF)),
          ),
        ],
      ),
    );
  }
}

// ===================== Camera + Painter =====================

class _CameraCover extends StatelessWidget {
  const _CameraCover({required this.camera});
  final CameraController camera;

  @override
  Widget build(BuildContext context) {
    final preview = camera.value.previewSize;
    if (preview == null) return CameraPreview(camera);
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: preview.height,
          height: preview.width,
          child: CameraPreview(camera),
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  _GamePainter(this.c);
  final GameController c;

  @override
  void paint(Canvas canvas, Size size) {
    final img = c.imageSize;
    if (img.width <= 1 || img.height <= 1) return;

    final srcAspect = img.width / img.height;
    final viewAspect = size.width / size.height;
    double sx, sy, ox = 0, oy = 0;
    if (srcAspect > viewAspect) {
      sy = size.height / img.height;
      sx = sy;
      ox = (size.width - img.width * sx) / 2;
    } else {
      sx = size.width / img.width;
      sy = sx;
      oy = (size.height - img.height * sy) / 2;
    }
    Offset mapN(Offset n) =>
        Offset(n.dx * img.width * sx + ox, n.dy * img.height * sy + oy);
    final unit = img.width * sx; // 1.0 (chuẩn hoá x) -> px canvas

    // Hoa quả / bom (xoay theo angle).
    for (final f in c.fruits) {
      final p = mapN(f.pos);
      _emoji(canvas, f.emoji, p, f.radius * unit * 1.9, angle: f.angle);
    }

    // Hạt nước văng khi chém.
    for (final pt in c.particles) {
      final life = pt.life.clamp(0.0, 1.0);
      final r = (pt.size * unit) * life + 1.0;
      canvas.drawCircle(
        mapN(pt.pos),
        r,
        Paint()..color = pt.color.withValues(alpha: life),
      );
    }

    // Vệt lưỡi dao: 3 lớp glow thon dần theo life (kiểu kiếm phát sáng).
    final tr = c.trail;
    for (var i = 1; i < tr.length; i++) {
      final a = mapN(tr[i - 1].pos);
      final b = mapN(tr[i].pos);
      final life = tr[i].life.clamp(0.0, 1.0);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = AppColors.ffFF8C00.withValues(alpha: 0.20 * life)
          ..strokeWidth = 26 * life
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = AppColors.ffFF8C00.withValues(alpha: 0.55 * life)
          ..strokeWidth = 14 * life
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = AppColors.ffFFFFFF.withValues(alpha: 0.95 * life)
          ..strokeWidth = 6 * life
          ..strokeCap = StrokeCap.round,
      );
    }

    // Đầu lưỡi dao (chấm sáng + quầng).
    final bl = c.blade;
    if (bl != null) {
      final p = mapN(bl);
      canvas.drawCircle(
          p, 16, Paint()..color = AppColors.ffFF8C00.withValues(alpha: 0.4));
      canvas.drawCircle(p, 6, Paint()..color = AppColors.ffFFFFFF);
    }
  }

  void _emoji(Canvas canvas, String e, Offset center, double fontSize,
      {double angle = 0}) {
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: e, style: TextStyle(fontSize: fontSize)),
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (angle != 0) canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GamePainter old) => true;
}
