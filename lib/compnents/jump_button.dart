import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:nextgrid/nextgrid.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<nextGrid>, TapCallbacks {
  JumpButton();
  final margin = 34;
  final buttonSize = 60;
  @override
  FutureOr<void> onLoad() {
    priority = 10;
    sprite = Sprite(
      game.images.fromCache('HUD/JumpButton.png'),
    );
    position = Vector2(
      game.size.x - margin - buttonSize,
      game.size.y - margin - buttonSize,
    );
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
