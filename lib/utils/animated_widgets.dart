import 'package:flutter/material.dart';

/// A card that fades and slides in when built, improving list animations.
class AnimatedListCard extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const AnimatedListCard({
    Key? key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + Duration(milliseconds: index * 50),
      builder: (context, value, child) {
        return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ));
      },
      child: child,
    );
  }
}
