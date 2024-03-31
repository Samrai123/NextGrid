import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:nextgrid/compnents/player.dart';

class Level extends World {
  final String levelName;
  final Player player;
  late TiledComponent level;

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    for (final spawnPoint in spawnPointLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          // final player = Player(
          //     character: 'Pink Man',
          //     position: Vector2(spawnPoint.x, spawnPoint.y));
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
        default:
      }
    }

    return super.onLoad();
  }
}
