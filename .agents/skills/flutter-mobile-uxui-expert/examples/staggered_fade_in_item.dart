import 'package:flutter/material.dart';

/// Widget Hiệu Ứng Xuất Hiện So Le (Staggered Entrance) Tối Ưu Cho Màn Hình Di Động
class StaggeredFadeInItem extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;
  final double slideOffset;

  const StaggeredFadeInItem({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
    this.slideOffset = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final double startTime = (index * 0.05).clamp(0.0, 0.6);
    final double endTime = (startTime + 0.35).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(startTime, endTime, curve: Curves.fastOutSlowIn),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - animation.value) * slideOffset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

