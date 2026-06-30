import 'dart:async';

import 'package:flutter/material.dart';

/// Nền ảnh tự chuyển qua lại giữa nhiều ảnh bằng hiệu ứng cross-fade,
/// kèm zoom nhẹ (Ken Burns) trong lúc chuyển.
///
/// Mỗi [interval] sẽ fade từ ảnh hiện tại sang ảnh kế trong [fade].
/// Hủy timer khi dispose nên an toàn cho test.
class CrossfadeBackground extends StatefulWidget {
  const CrossfadeBackground({
    super.key,
    required this.images,
    this.interval = const Duration(milliseconds: 3800),
    this.fade = const Duration(milliseconds: 1200),
    this.fit = BoxFit.cover,
  });

  final List<String> images;
  final Duration interval;
  final Duration fade;
  final BoxFit fit;

  @override
  State<CrossfadeBackground> createState() => _CrossfadeBackgroundState();
}

class _CrossfadeBackgroundState extends State<CrossfadeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.fade);
  Timer? _timer;
  int _front = 0; // ảnh đang hiển thị
  int _back = 0; // ảnh sẽ fade tới

  @override
  void initState() {
    super.initState();
    _back = widget.images.length > 1 ? 1 : 0;
    if (widget.images.length > 1) {
      _timer = Timer.periodic(widget.interval, (_) => _advance());
    }
  }

  void _advance() {
    if (!mounted) return;
    _c.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _front = _back;
        _back = (_back + 1) % widget.images.length;
      });
      _c.value = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  Widget _img(int i) => Image.asset(
        widget.images[i],
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    if (widget.images.length == 1) return _img(0);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh hiện tại: zoom nhẹ ra trong lúc fade.
            Transform.scale(scale: 1.0 + 0.04 * t, child: _img(_front)),
            // Ảnh kế: mờ dần hiện lên, zoom vào.
            Opacity(
              opacity: t,
              child: Transform.scale(scale: 1.06 - 0.06 * t, child: _img(_back)),
            ),
          ],
        );
      },
    );
  }
}
