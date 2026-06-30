import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hand_detection/hand_detection_native.dart';

import '../../resource/app_colors.dart';

/// Quản lý camera + hand tracking + state vẽ cho màn Draw.
///
/// Luồng: camera stream -> [HandDetector.detectFromCameraImage] (chạy isolate)
/// -> tính cử chỉ pinch (ngón cái + ngón trỏ) -> gom điểm thành nét vẽ.
class DrawController extends GetxController {
  CameraController? camera;
  HandDetector? _detector;

  bool _processing = false;

  /// Sẵn sàng hiển thị preview hay chưa.
  bool isReady = false;

  /// Lỗi khởi tạo (nếu có) để hiển thị cho người dùng.
  String? errorMessage;

  /// Kích thước ảnh nguồn (sau xoay) — dùng để map toạ độ ở painter.
  Size imageSize = const Size(1, 1);

  /// Có phải camera trước không (dùng cho tính rotation).
  bool isFront = true;

  /// Có lật X khi vẽ overlay không (khớp preview). Tách khỏi [isFront].
  bool mirror = false;

  /// Các nét đã chốt. Mỗi nét là list Offset theo pixel ảnh nguồn.
  final List<List<Offset>> strokes = [];

  /// Nét đang vẽ.
  List<Offset> current = [];

  /// Vị trí con trỏ (đầu ngón trỏ) theo pixel ảnh nguồn; null nếu mất tay.
  Offset? cursor;

  /// Đang hạ bút hay không.
  bool isDrawing = false;

  /// Đang ở chế độ tẩy (chụm trỏ + giữa) hay không.
  bool isErasing = false;

  /// Bán kính tẩy (theo pixel ảnh nguồn).
  double eraseRadius = 40;

  /// Số frame liên tiếp không bắt được ngón; vượt ngưỡng mới nhấc bút
  /// (tránh đứt nét khi detect chập chờn 1-2 frame).
  int _missCount = 0;
  static const int _maxMiss = 6;

  // --- Debug: hiển thị lên màn để tune ---
  int handsCount = 0;
  int frames = 0;
  String debugInfo = '-';
  String rotLabel = 'none';

  /// Màu và độ dày brush.
  Color brushColor = AppColors.ff43A649;
  double brushWidth = 5;

  @override
  void onInit() {
    super.onInit();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final cameras = await availableCameras();
      debugPrint('[draw] availableCameras: ${cameras.length}');
      if (cameras.isEmpty) {
        errorMessage =
            'Không tìm thấy camera.\niOS Simulator không có camera — '
            'hãy chạy trên iPhone thật.';
        update();
        return;
      }
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      isFront = front.lensDirection == CameraLensDirection.front;
      // Cursor/nét vẽ bị lật X so với tay -> KHÔNG lật thêm (đã test trên iOS).
      mirror = false;

      final cam = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        // Theo example của package: yuv420 cho cả iOS & Android.
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      camera = cam;
      await cam.initialize();
      debugPrint('[draw] camera initialized: ${cam.value.previewSize}');

      _detector = await HandDetector.create(
        maxDetections: 1,
        detectorConf: 0.35,
        enableGestures: true,
        gestureMinConfidence: 0.4,
        // GPU/Metal delegate trên iOS bị xung đột class (LiteRt vs
        // LiteRtMetalAccelerator) -> inference rỗng. Ép CPU cho ổn định.
        accelerators: const {Accelerator.cpu},
      );
      debugPrint('[draw] detector created');

      await cam.startImageStream(_onFrame);
      debugPrint('[draw] image stream started');
      isReady = true;
      update();
    } catch (e, st) {
      debugPrint('[draw] SETUP ERROR: $e\n$st');
      errorMessage = 'Không khởi tạo được camera: $e';
      update();
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    frames++;
    if (frames == 1) {
      final p = image.planes.first;
      debugPrint('[draw] planes=${image.planes.length} '
          '${image.width}x${image.height} bytesPerRow=${p.bytesPerRow} '
          'bytesPerPixel=${p.bytesPerPixel} len=${p.bytes.length} '
          'expect(w*4)=${image.width * 4} expect(total)=${p.bytesPerRow * image.height}');
    }
    if (frames <= 3 || frames % 30 == 0) {
      debugPrint('[draw] frame $frames ${image.width}x${image.height} '
          'fmt=${image.format.group}');
      update(); // cập nhật bộ đếm lên debug bar
    }
    final detector = _detector;
    final cam = camera;
    if (detector == null || cam == null || _processing) return;
    _processing = true;
    try {
      final rot = rotationForFrame(
        width: image.width,
        height: image.height,
        sensorOrientation: cam.description.sensorOrientation,
        isFrontCamera: isFront,
        deviceOrientation: DeviceOrientation.portraitUp,
      );
      rotLabel = rot?.name ?? 'none';

      final hands = await detector.detectFromCameraImage(
        image,
        rotation: rot,
        isBgra: Platform.isMacOS, // iOS & Android dùng yuv420 -> false
        maxDim: 384, // nhỏ hơn -> suy luận nhanh -> nhiều fps -> ổn định hơn

      );

      if (frames % 15 == 0) {
        debugPrint('[draw] rot=$rotLabel -> hands:${hands.length}'
            '${hands.isNotEmpty ? " g:${hands.first.gesture?.type.name}" : ""}');
      }
      _handleHands(hands);
    } catch (e) {
      // Hiện lỗi để chẩn đoán (đừng nuốt im lặng).
      debugPrint('[draw] DETECT ERROR: $e');
      debugInfo = 'err: $e';
      update();
    } finally {
      _processing = false;
    }
  }

  void _handleHands(List<Hand> hands) {
    handsCount = hands.length;
    if (hands.isEmpty) {
      _noDraw('Không thấy tay');
      return;
    }

    final hand = hands.first;
    imageSize = Size(hand.imageWidth.toDouble(), hand.imageHeight.toDouble());

    final wrist = hand.getLandmark(HandLandmarkType.wrist);
    final index = hand.getLandmark(HandLandmarkType.indexFingerTip);
    if (wrist == null) {
      _noDraw('Thiếu landmark');
      return;
    }

    // --- Chế độ TẨY: chụm ngón trỏ + giữa sát nhau, di chuyển để xoá ---
    final middleTip = hand.getLandmark(HandLandmarkType.middleFingerTip);
    final indexPip = hand.getLandmark(HandLandmarkType.indexFingerPIP);
    final middlePip = hand.getLandmark(HandLandmarkType.middleFingerPIP);
    final indexMcp = hand.getLandmark(HandLandmarkType.indexFingerMCP);
    if (index != null &&
        middleTip != null &&
        indexPip != null &&
        middlePip != null &&
        indexMcp != null) {
      final iExt = _dist(index, wrist) > _dist(indexPip, wrist);
      final mExt = _dist(middleTip, wrist) > _dist(middlePip, wrist);
      final tipGap = _dist(index, middleTip);
      final fingerLen = _dist(index, indexMcp);
      // Hai ngón cùng duỗi và 2 đầu ngón gần nhau (< 60% chiều dài ngón) = chụm.
      if (iExt && mExt && fingerLen > 0 && tipGap < 0.6 * fingerLen) {
        _missCount = 0;
        isDrawing = false;
        isErasing = true;
        _liftPen(); // chốt nét đang vẽ trước khi tẩy
        eraseRadius = imageSize.width * 0.07;
        final ePos = Offset(
            (index.x + middleTip.x) / 2, (index.y + middleTip.y) / 2);
        _eraseAt(ePos);
        cursor = ePos;
        debugInfo = 'ERASE';
        update();
        return;
      }
    }
    isErasing = false;

    // Xét cả 5 ngón. Ngón "đang duỗi" = đầu ngón xa cổ tay hơn khớp giữa.
    // Chọn ngón "rõ nhất" = đầu ngón duỗi xa cổ tay nhất -> điểm vẽ.
    // Bất kỳ ngón nào giơ cũng vẽ; xòe cả bàn tay thì lấy ngón nổi nhất.
    // Bỏ ngón cái: trong nắm tay ngón cái hay thò ngang -> dễ bị tính "duỗi".
    const fingers = [
      (HandLandmarkType.indexFingerTip, HandLandmarkType.indexFingerPIP, 'index'),
      (HandLandmarkType.middleFingerTip, HandLandmarkType.middleFingerPIP, 'middle'),
      (HandLandmarkType.ringFingerTip, HandLandmarkType.ringFingerPIP, 'ring'),
      (HandLandmarkType.pinkyTip, HandLandmarkType.pinkyPIP, 'pinky'),
    ];

    HandLandmark? best;
    String bestName = '-';
    double bestDist = 0;
    var extended = 0;
    for (final f in fingers) {
      final tip = hand.getLandmark(f.$1);
      final pip = hand.getLandmark(f.$2);
      if (tip == null || pip == null) continue;
      final dTip = _dist(tip, wrist);
      if (dTip > _dist(pip, wrist)) {
        extended++;
        if (dTip > bestDist) {
          bestDist = dTip;
          best = tip;
          bestName = f.$3;
        }
      }
    }

    if (best != null) {
      _missCount = 0;
      isDrawing = true;
      cursor = Offset(best.x, best.y);
      current.add(Offset(best.x, best.y));
      debugInfo = 'fingers:$extended draw:$bestName';
      update();
    } else {
      // Nắm tay: hiện cursor mờ ở ngón trỏ (nếu có) rồi grace -> nhấc bút.
      if (index != null) cursor = Offset(index.x, index.y);
      _noDraw('fingers:0');
    }
  }

  /// Không bắt được ngón: đếm miss; vượt ngưỡng mới chốt nét + ẩn cursor
  /// (giữ nét liền mạch khi detect chập chờn vài frame).
  void _noDraw(String info) {
    isErasing = false;
    _missCount++;
    if (_missCount >= _maxMiss) {
      _liftPen();
      cursor = null;
    }
    debugInfo = info;
    update();
  }

  double _dist(HandLandmark a, HandLandmark b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Xoá các điểm nằm trong bán kính tẩy quanh [p]; cắt nét thành các đoạn còn lại.
  void _eraseAt(Offset p) {
    final r2 = eraseRadius * eraseRadius;
    final out = <List<Offset>>[];
    for (final stroke in strokes) {
      var seg = <Offset>[];
      for (final pt in stroke) {
        final dx = pt.dx - p.dx;
        final dy = pt.dy - p.dy;
        if (dx * dx + dy * dy <= r2) {
          if (seg.length >= 2) out.add(seg);
          seg = <Offset>[];
        } else {
          seg.add(pt);
        }
      }
      if (seg.length >= 2) out.add(seg);
    }
    strokes
      ..clear()
      ..addAll(out);
  }

  /// Nhả bút: chốt nét hiện tại vào danh sách.
  void _liftPen() {
    if (current.isNotEmpty) {
      strokes.add(List<Offset>.from(current));
      current = [];
    }
    isDrawing = false;
  }

  /// Xoá toàn bộ nét vẽ.
  void clear() {
    strokes.clear();
    current = [];
    update();
  }

  void onBack() {
    Get.back();
  }

  @override
  void onClose() {
    camera?.stopImageStream().catchError((_) {});
    camera?.dispose();
    _detector?.dispose();
    super.onClose();
  }
}
