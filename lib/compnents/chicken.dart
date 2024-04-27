import 'dart:async';

import 'package:flame/components.dart';

enum state { idle, run, hit }

class Chicken extends SpriteAnimationComponent {
  final double offNeg;
  final double offPos;
  Chicken({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });
  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    _loadAllAnimation();
    return super.onLoad();
  }

  void _loadAllAnimation() {}
}
