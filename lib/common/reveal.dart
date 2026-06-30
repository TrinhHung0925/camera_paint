import 'dart:async';

import 'package:flutter/material.dart';

/// Cột có hiệu ứng "hiện ra từng cái": mỗi child con lần lượt mờ dần hiện lên
/// kèm trượt nhẹ từ dưới lên, lệch nhau [stagger].
///
/// Dùng thay cho [Column] gần như nguyên xi (giữ crossAxisAlignment / children).
/// An toàn layout: hiệu ứng chỉ tác động lúc vẽ (Opacity + Transform.translate),
/// KHÔNG đổi kích thước nên không gây overflow. Các child là
/// [Expanded]/[Flexible]/[Spacer]/[SizedBox] được giữ nguyên (không bọc).
///
/// [startDelay] trì hoãn bắt đầu để reveal diễn ra SAU khi chuyển route/trang
/// (nếu chạy ngay lúc route đang trượt vào sẽ bị che, trông như không có hiệu ứng).
class RevealGroup extends StatefulWidget {
  const RevealGroup({
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.stagger = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 460),
    this.startDelay = const Duration(milliseconds: 320),
    required this.children,
  });

  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final Duration stagger;
  final Duration duration;
  final Duration startDelay;
  final List<Widget> children;

  @override
  State<RevealGroup> createState() => _RevealGroupState();
}

class _RevealGroupState extends State<RevealGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Timer? _startTimer;

  bool _isFlex(Widget w) => w is Expanded || w is Flexible || w is Spacer;
  bool _skip(Widget w) => _isFlex(w) || w is SizedBox;

  int get _revealCount => widget.children.where((w) => !_skip(w)).length;

  @override
  void initState() {
    super.initState();
    final totalMs = widget.duration.inMilliseconds +
        widget.stagger.inMilliseconds * (_revealCount + 1);
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs.clamp(1, 1 << 30)),
    );
    if (widget.startDelay == Duration.zero) {
      _c.forward();
    } else {
      _startTimer = Timer(widget.startDelay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _c.duration!.inMilliseconds;
    final children = <Widget>[];
    var i = 0;
    for (final child in widget.children) {
      if (_skip(child)) {
        children.add(child);
        continue;
      }
      final startMs = widget.stagger.inMilliseconds * i;
      final endMs = (startMs + widget.duration.inMilliseconds).clamp(1, totalMs);
      children.add(_RevealItem(
        animation: CurvedAnimation(
          parent: _c,
          curve: Interval(startMs / totalMs, endMs / totalMs,
              curve: Curves.easeOut),
        ),
        child: child,
      ));
      i++;
    }
    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisAlignment: widget.mainAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      children: children,
    );
  }
}

/// Một item reveal đơn lẻ (fade + trượt lên 16px) dùng với [Animation] cấp ngoài.
class RevealItem extends StatelessWidget {
  const RevealItem({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _RevealItem(animation: animation, child: child);
}

class _RevealItem extends AnimatedWidget {
  const _RevealItem({required this.animation, required this.child})
      : super(listenable: animation);

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final v = animation.value.clamp(0.0, 1.0);
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, (1 - v) * 16),
        child: child,
      ),
    );
  }
}
