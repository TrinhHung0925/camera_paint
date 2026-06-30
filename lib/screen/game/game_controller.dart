import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hand_detection/hand_detection_native.dart';

import '../../resource/app_colors.dart';

enum GamePhase { countdown, playing, gameOver }

/// Một quả (hoặc bom) trong game. Toạ độ chuẩn hoá 0..1 theo ảnh nguồn.
class Fruit {
  Fruit({
    required this.pos,
    required this.vel,
    required this.radius,
    required this.emoji,
    required this.bomb,
    required this.juice,
    required this.spin,
  });

  Offset pos;
  Offset vel;
  double radius;
  String emoji;
  bool bomb;
  Color juice; // màu nước văng khi chém
  double spin; // tốc độ xoay (rad/s)
  double angle = 0; // góc xoay hiện tại
  bool sliced = false;
}

/// Điểm trên vệt lưỡi dao (có "tuổi" để mờ dần).
class TrailPoint {
  TrailPoint(this.pos, this.life);
  Offset pos;
  double life;
}

/// Hạt nước/mảnh văng ra khi chém.
class Particle {
  Particle({
    required this.pos,
    required this.vel,
    required this.color,
    required this.size,
    this.life = 1,
  });
  Offset pos;
  Offset vel;
  Color color;
  double size; // chuẩn hoá
  double life;
}

/// Game "chém hoa quả trên không": đầu ngón tay = lưỡi dao, chém quả bay
/// ngang khung camera. Vào màn đếm ngược 3-2-1 rồi mới chơi.
class GameController extends GetxController {
  // --- Camera + hand tracking ---
  CameraController? camera;
  HandDetector? _detector;
  bool _processing = false;
  bool isReady = false;
  String? errorMessage;
  bool isFront = true;
  Size imageSize = const Size(1, 1);

  /// Bơm repaint cho painter ở 60fps (tách khỏi update() của HUD).
  final ValueNotifier<int> repaintTick = ValueNotifier(0);

  // --- Trạng thái game ---
  GamePhase phase = GamePhase.countdown;
  double _countdownT = 3.0;
  int get countdown => _countdownT.ceil(); // 3, 2, 1
  int score = 0;
  int lives = 3;

  /// Thời gian còn lại của ván (giây).
  static const double gameDuration = 60;
  double timeLeft = gameDuration;
  int get timeLeftSec => timeLeft.ceil().clamp(0, 999);

  /// Màn hiện tại (độ khó tăng dần theo level).
  int level = 1;

  /// > 0: đang hiện banner "LEVEL n".
  double levelBannerT = 0;

  final List<Fruit> fruits = [];
  double _spawnT = 0;
  final _rand = Random();

  // --- Lưỡi dao (đầu ngón) ---
  Offset? blade; // vị trí mượt (nội suy) 0..1
  Offset? bladePrev;
  Offset? _target; // vị trí thô từ detection (cập nhật chậm)
  final List<TrailPoint> trail = [];

  /// Hạt văng ra khi chém.
  final List<Particle> particles = [];

  // --- Âm thanh ---
  final List<AudioPlayer> _popPool = List.generate(3, (_) => AudioPlayer());
  int _popIdx = 0;
  final AudioPlayer _bombSfx = AudioPlayer();
  final AudioPlayer _beepSfx = AudioPlayer();
  final AudioPlayer _overSfx = AudioPlayer();
  int _lastBeep = 0;

  static const _fruitEmojis = ['🍉', '🍎', '🍊', '🍋', '🍇', '🍓', '🥝', '🍑'];

  @override
  void onInit() {
    super.onInit();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        errorMessage = 'Không tìm thấy camera.\nHãy chạy trên điện thoại thật.';
        update();
        return;
      }
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      isFront = front.lensDirection == CameraLensDirection.front;
      final cam = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      camera = cam;
      await cam.initialize();
      _detector = await HandDetector.create(
        maxDetections: 1,
        detectorConf: 0.35,
        accelerators: const {Accelerator.cpu},
      );
      await _initAudio(); // preload trước để không trễ tiếng
      await cam.startImageStream(_onFrame);
      isReady = true;
      update();
    } catch (e) {
      errorMessage = 'Lỗi khởi tạo camera: $e';
      update();
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    final det = _detector;
    final cam = camera;
    if (det == null || cam == null || _processing) return;
    _processing = true;
    try {
      final rot = rotationForFrame(
        width: image.width,
        height: image.height,
        sensorOrientation: cam.description.sensorOrientation,
        isFrontCamera: isFront,
        deviceOrientation: DeviceOrientation.portraitUp,
      );
      final hands = await det.detectFromCameraImage(
        image,
        rotation: rot,
        isBgra: Platform.isMacOS,
        maxDim: 384,
      );
      _onHand(hands);
    } catch (_) {
      // bỏ qua frame lỗi
    } finally {
      _processing = false;
    }
  }

  void _onHand(List<Hand> hands) {
    if (hands.isEmpty) {
      _target = null;
      return;
    }
    final hand = hands.first;
    imageSize = Size(hand.imageWidth.toDouble(), hand.imageHeight.toDouble());
    // Dùng đầu ngón trỏ làm điểm lưỡi dao (ổn định, ít nhảy giữa các ngón).
    final tip = hand.getLandmark(HandLandmarkType.indexFingerTip) ??
        hand.getLandmark(HandLandmarkType.middleFingerTip);
    if (tip == null) {
      _target = null;
      return;
    }
    _target = Offset(tip.x / imageSize.width, tip.y / imageSize.height);
  }

  /// Nội suy lưỡi dao ở 60fps về phía [_target] để chuyển động mượt + chém theo
  /// tốc độ vung (vung nhanh mới đứt).
  void _updateBlade(double dt) {
    final tgt = _target;
    if (tgt == null) {
      blade = null;
      bladePrev = null;
      return;
    }
    final cur = blade;
    if (cur == null) {
      blade = tgt;
      bladePrev = tgt;
      return;
    }
    final f = (dt * 18).clamp(0.0, 1.0);
    final next = Offset.lerp(cur, tgt, f)!;
    bladePrev = cur;
    blade = next;
    trail.add(TrailPoint(next, 1.0));
    if (phase == GamePhase.playing) {
      final speed = (next - cur).distance / (dt <= 0 ? 0.016 : dt);
      if (speed >= 0.6) _checkSlice(cur, next); // vung đủ nhanh mới chém
    }
  }

  void _checkSlice(Offset a, Offset b) {
    for (final f in fruits) {
      if (f.sliced) continue;
      if (_segCircleHit(a, b, f.pos, f.radius)) {
        f.sliced = true;
        if (f.bomb) {
          _spawnParticles(f.pos, AppColors.ffFF8C00, n: 22, boom: true);
          _bombSfx.seek(Duration.zero);
          _bombSfx.resume();
          _gameOver();
          return;
        }
        score += 1;
        _spawnParticles(f.pos, f.juice);
        _playPop();
      }
    }
  }

  bool _segCircleHit(Offset a, Offset b, Offset c, double r) {
    final ab = b - a;
    final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
    final ac = c - a;
    var t = ab2 == 0 ? 0.0 : (ac.dx * ab.dx + ac.dy * ab.dy) / ab2;
    t = t.clamp(0.0, 1.0);
    final closest = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (c - closest).distance <= r;
  }

  /// Vòng lặp game (gọi từ Ticker của view), [dt] tính bằng giây.
  void onTick(double dt) {
    _updateBlade(dt); // nội suy lưỡi dao mượt + chém theo tốc độ

    if (phase == GamePhase.countdown) {
      final cd = countdown;
      if (cd != _lastBeep && cd >= 1 && cd <= 3) {
        _lastBeep = cd;
        _beepSfx.seek(Duration.zero);
        _beepSfx.resume();
      }
      _countdownT -= dt;
      if (_countdownT <= 0) phase = GamePhase.playing;
    } else if (phase == GamePhase.playing) {
      // Đếm ngược thời gian ván.
      timeLeft -= dt;
      if (timeLeft <= 0) {
        timeLeft = 0;
        _gameOver();
      }

      // Spawn theo nhịp giảm dần theo level.
      _spawnT -= dt;
      if (_spawnT <= 0) {
        final n = level >= 4 ? 2 : 1;
        for (var i = 0; i < n; i++) {
          _spawn();
        }
        _spawnT = max(0.35, 0.85 - level * 0.05) + _rand.nextDouble() * 0.3;
      }

      const g = 0.4; // trọng lực nhẹ (quả đã rơi sẵn từ trên)
      for (final f in fruits) {
        f.vel = Offset(f.vel.dx, f.vel.dy + g * dt);
        f.pos = f.pos + f.vel * dt;
        f.angle += f.spin * dt;
      }
      fruits.removeWhere((f) {
        final gone = f.pos.dy > 1.25;
        if (gone && !f.sliced && !f.bomb) lives--;
        return gone || f.sliced;
      });
      if (lives <= 0) _gameOver();

      // Lên level theo điểm (mỗi 8 quả 1 level).
      final target = 1 + score ~/ 8;
      if (target > level) {
        level = target;
        levelBannerT = 1.3;
      }
      if (levelBannerT > 0) levelBannerT -= dt;
    }

    for (final tp in trail) {
      tp.life -= dt * 3.0;
    }
    trail.removeWhere((tp) => tp.life <= 0);

    // Cập nhật hạt văng.
    for (final p in particles) {
      p.vel = Offset(p.vel.dx, p.vel.dy + 0.9 * dt);
      p.pos = p.pos + p.vel * dt;
      p.life -= dt * 1.6;
    }
    particles.removeWhere((p) => p.life <= 0);

    repaintTick.value++;
  }

  void _spawn() {
    final bombChance = min(0.30, 0.12 + level * 0.02);
    final bomb = _rand.nextDouble() < bombChance;
    final x = 0.1 + _rand.nextDouble() * 0.8;
    // Rơi từ TRÊN xuống nhưng BAY CHÉO: lệch về giữa nếu ở mép + ngẫu nhiên.
    final vx = (0.5 - x) * 0.4 + (_rand.nextDouble() - 0.5) * 0.45;
    final vy = 0.26 + level * 0.03 + _rand.nextDouble() * 0.2;
    final emoji = bomb ? '💣' : _fruitEmojis[_rand.nextInt(_fruitEmojis.length)];
    fruits.add(Fruit(
      pos: Offset(x, -0.12),
      vel: Offset(vx, vy),
      radius: 0.085 + _rand.nextDouble() * 0.035, // to/nhỏ ngẫu nhiên
      emoji: emoji,
      bomb: bomb,
      juice: bomb ? AppColors.ffFF8C00 : _juiceFor(emoji),
      spin: (_rand.nextDouble() - 0.5) * 4.0, // xoay ±2 rad/s
    ));
  }

  void _gameOver() {
    if (phase == GamePhase.gameOver) return;
    phase = GamePhase.gameOver;
    _overSfx.seek(Duration.zero);
    _overSfx.resume();
  }

  void restart() {
    fruits.clear();
    trail.clear();
    particles.clear();
    _lastBeep = 0;
    score = 0;
    lives = 3;
    level = 1;
    levelBannerT = 0;
    timeLeft = gameDuration;
    _countdownT = 3.0;
    _spawnT = 0;
    blade = null;
    bladePrev = null;
    phase = GamePhase.countdown;
  }

  // --- Âm thanh (preload lowLatency để phát tức thì) ---
  Future<void> _initAudio() async {
    Future<void> prep(AudioPlayer p, String f) async {
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setPlayerMode(PlayerMode.lowLatency);
      await p.setSource(AssetSource('sounds/$f'));
    }

    try {
      for (final p in _popPool) {
        await prep(p, 'pop.wav');
      }
      await prep(_bombSfx, 'bomb.wav');
      await prep(_beepSfx, 'beep.wav');
      await prep(_overSfx, 'over.wav');
    } catch (_) {
      // bỏ qua nếu thiết bị không phát được
    }
  }

  void _sfx(AudioPlayer p) {
    p.seek(Duration.zero);
    p.resume();
  }

  void _playPop() {
    final p = _popPool[_popIdx];
    _popIdx = (_popIdx + 1) % _popPool.length;
    _sfx(p);
  }

  // --- Hạt văng khi chém ---
  void _spawnParticles(Offset at, Color color, {int n = 12, bool boom = false}) {
    for (var i = 0; i < n; i++) {
      final ang = _rand.nextDouble() * 2 * pi;
      final spd = (boom ? 0.55 : 0.32) * (0.4 + _rand.nextDouble());
      particles.add(Particle(
        pos: at,
        vel: Offset(cos(ang) * spd, sin(ang) * spd),
        color: color,
        size: (boom ? 0.02 : 0.013) * (0.6 + _rand.nextDouble()),
      ));
    }
  }

  Color _juiceFor(String e) {
    switch (e) {
      case '🍉':
      case '🍎':
      case '🍓':
        return AppColors.ffE53935;
      case '🍊':
      case '🍑':
        return AppColors.ffFF8C00;
      case '🍋':
        return AppColors.ffF59E0B;
      case '🥝':
        return AppColors.ff43A649;
      case '🍇':
        return AppColors.ff8E44AD;
      default:
        return AppColors.ffFF8C00;
    }
  }

  void onBack() => Get.back();

  @override
  void onClose() {
    camera?.stopImageStream().catchError((_) {});
    camera?.dispose();
    _detector?.dispose();
    for (final p in [..._popPool, _bombSfx, _beepSfx, _overSfx]) {
      p.dispose();
    }
    repaintTick.dispose();
    super.onClose();
  }
}
