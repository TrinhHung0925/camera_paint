import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../resource/app_colors.dart';
import '../../resource/app_text.dart';
import 'draw_controller.dart';

class DrawView extends StatefulWidget {
  DrawView({super.key}) {
    if (!Get.isRegistered<DrawController>()) {
      Get.put(DrawController());
    }
  }

  @override
  State<DrawView> createState() => _DrawViewState();
}

class _DrawViewState extends State<DrawView> {
  final controller = Get.find<DrawController>();

  @override
  void dispose() {
    Get.delete<DrawController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ff000000,
      body: GetBuilder<DrawController>(
        builder: (c) {
          if (c.errorMessage != null) {
            return _ErrorBox(message: c.errorMessage!);
          }
          if (!c.isReady || c.camera == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.ffFFFFFF),
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              // Preview camera giữ đúng tỉ lệ, phủ kín màn (cover) -> không méo.
              _CameraCover(camera: c.camera!),
              // Lớp vẽ + cursor đầu ngón trỏ.
              CustomPaint(
                painter: _DrawPainter(
                  strokes: c.strokes,
                  current: c.current,
                  cursor: c.cursor,
                  imageSize: c.imageSize,
                  mirror: c.mirror,
                  brushColor: c.brushColor,
                  brushWidth: c.brushWidth,
                  isDrawing: c.isDrawing,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(bottom: false, child: _TopBar(controller: c)),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(top: false, child: _DebugBar(controller: c)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final DrawController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          _circleBtn(Icons.arrow_back, controller.onBack),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.overlayDim,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              controller.isDrawing ? '✍️ Đang vẽ' : '☝️ Giơ 1 ngón trỏ để vẽ',
              style: AppText.regular14.copyWith(color: AppColors.ffFFFFFF),
            ),
          ),
          const Spacer(),
          _circleBtn(Icons.delete_outline, controller.clear),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
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
}

class _CameraCover extends StatelessWidget {
  const _CameraCover({required this.camera});

  final CameraController camera;

  @override
  Widget build(BuildContext context) {
    final preview = camera.value.previewSize;
    if (preview == null) return CameraPreview(camera);

    // previewSize ở hệ landscape của sensor; ở portrait phải đảo width/height.
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

class _DebugBar extends StatelessWidget {
  const _DebugBar({required this.controller});

  final DrawController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      color: AppColors.overlayDim,
      child: Text(
        'f:${controller.frames} h:${controller.handsCount} rot:${controller.rotLabel} | ${controller.debugInfo}',
        style: AppText.regular14.copyWith(color: AppColors.ffFFFFFF),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppText.regular14.copyWith(color: AppColors.ffFFFFFF),
        ),
      ),
    );
  }
}

class _DrawPainter extends CustomPainter {
  _DrawPainter({
    required this.strokes,
    required this.current,
    required this.cursor,
    required this.imageSize,
    required this.mirror,
    required this.brushColor,
    required this.brushWidth,
    required this.isDrawing,
  });

  final List<List<Offset>> strokes;
  final List<Offset> current;
  final Offset? cursor;
  final Size imageSize;
  final bool mirror;
  final Color brushColor;
  final double brushWidth;
  final bool isDrawing;

  @override
  void paint(Canvas canvas, Size size) {
    final src = imageSize;
    if (src.width <= 1 || src.height <= 1) return;

    final sourceAspect = src.width / src.height;
    final viewAspect = size.width / size.height;

    double scaleX, scaleY, offsetX = 0, offsetY = 0;
    if (sourceAspect > viewAspect) {
      scaleY = size.height / src.height;
      scaleX = scaleY;
      offsetX = (size.width - src.width * scaleX) / 2;
    } else {
      scaleX = size.width / src.width;
      scaleY = scaleX;
      offsetY = (size.height - src.height * scaleY) / 2;
    }

    Offset map(Offset p) {
      final x = mirror
          ? (src.width - p.dx) * scaleX + offsetX
          : p.dx * scaleX + offsetX;
      final y = p.dy * scaleY + offsetY;
      return Offset(x, y);
    }

    final paint = Paint()
      ..color = brushColor
      ..strokeWidth = brushWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, map, paint);
    }
    _drawStroke(canvas, current, map, paint);

    // Cursor = icon cây bút tại đầu ngón.
    final c = cursor;
    if (c != null) {
      _drawPenCursor(canvas, map(c));
    }
  }

  void _drawPenCursor(Canvas canvas, Offset p) {
    const icon = Icons.brush;
    final color = isDrawing ? brushColor : AppColors.ffFFFFFF;
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 34,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
          shadows: const [
            Shadow(color: AppColors.ff000000, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      ),
    )..layout();
    // Icons.brush có đầu cọ ở góc dưới-trái -> canh đầu cọ vào điểm ngón tay.
    tp.paint(canvas, Offset(p.dx - tp.width * 0.08, p.dy - tp.height * 0.92));
  }

  void _drawStroke(
    Canvas canvas,
    List<Offset> stroke,
    Offset Function(Offset) map,
    Paint paint,
  ) {
    if (stroke.isEmpty) return;
    if (stroke.length == 1) {
      canvas.drawCircle(
        map(stroke.first),
        brushWidth / 2,
        Paint()..color = brushColor,
      );
      return;
    }
    final path = Path()..moveTo(map(stroke.first).dx, map(stroke.first).dy);
    for (var i = 1; i < stroke.length; i++) {
      final p = map(stroke[i]);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawPainter old) => true;
}
