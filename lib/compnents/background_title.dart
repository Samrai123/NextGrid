// import 'dart:async';

// import 'package:flame/components.dart';
// import 'package:flame/parallax.dart';
// import 'package:flutter/material.dart';
// import 'package:nextgrid/nextgrid.dart';

// class BackgroundTile extends ParallaxComponent {
//   final String color;
//   BackgroundTile({
//     this.color = 'Gray',
//     position,
//   }) : super(
//           position: position,
//         );
//   final double scrollSpeed = 40;
//   // @override
//   // FutureOr<void> onLoad() {
//   //   priority = -1;
//   //   size = Vector2.all(64.6);
//   //   sprite = Sprite(game.images.fromCache('Background/$color.png'));
//   //   return super.onLoad();
//   // }

//   // @override
//   // void update(double dt) {
//   //   position.y += scrollSpeed;
//   //   double tileSize = 64;
//   //   int scrollHeigth = (game.size.y / tileSize).round();
//   //   if (position.y > scrollHeigth * tileSize) position.y = -tileSize;
//   //   super.update(dt);
//   // }
//   @override
//   FutureOr<void> onLoad() async {
//     priority = -10;
//     size = Vector2.all(64);
//     parallax = await gameRef.loadParallax(
//       [ParallaxImageData('Background/$color.png')],
//       baseVelocity: Vector2(0, -scrollSpeed),
//       repeat: ImageRepeat.repeat,
//       fill: LayerFill.none,
//     );
//     return super.onLoad();
//   }
// }
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;
  BackgroundTile({
    this.color = 'Gray',
    position,
  }) : super(
          position: position,
        );

  final double scrollSpeed = 40;

  @override
  FutureOr<void> onLoad() async {
    priority = -10;
    size = Vector2.all(64);

    parallax = await game.loadParallax(
      [ParallaxImageData('Background/$color.png')],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );
    return super.onLoad();
  }
}
