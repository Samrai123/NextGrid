import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:nextgrid/compnents/custom_hitbox.dart';
import 'package:nextgrid/nextgrid.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<nextGrid>, CollisionCallbacks {
  final String fruit;
  Fruit({position, size, this.fruit = 'Apple'})
      : super(position: position, size: size, removeOnFinish: true);
  // bool _collected = false;
  final double stepTime = 0.05;
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);
  bool collected = false;
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = -1;
    colliedWithPlayer();
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,
    ));
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/$fruit.png'),
        SpriteAnimationData.sequenced(
          amount: 17,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ));
    return super.onLoad();
  }

  void colliedWithPlayer() async {
    if (!collected) {
      if (game.playSounds)
        FlameAudio.play('collectFruit.wav', volume: game.soundVolume * .5);
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
          'Items/Fruits/Collected.png',
        ),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );
    }
    await animationTicker?.completed;
    removeFromParent();
  }
}
