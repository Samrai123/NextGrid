import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:nextgrid/compnents/background_title.dart';
import 'package:nextgrid/compnents/collision_block.dart';
import 'package:nextgrid/compnents/fruit.dart';

import 'package:nextgrid/compnents/player.dart';
import 'package:nextgrid/compnents/saw.dart';
import 'package:nextgrid/nextgrid.dart';

class Level extends World with HasGameRef<nextGrid> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    _scrollingBackground();
    _spawningObjects();
    _addCollision();

    return super.onLoad();
  }

  void _addCollision() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  void _spawningObjects() {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            // final player = Player(
            //     character: 'Pink Man',
            //     position: Vector2(spawnPoint.x, spawnPoint.y));
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
                fruit: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offPos = spawnPoint.properties.getValue('offPos');
            final offNeg = spawnPoint.properties.getValue('offNeg');

            final saw = Saw(
                isVertical: isVertical,
                offNeg: offNeg,
                offPos: offPos,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(saw);
          default:
        }
      }
    }
  }

  void _scrollingBackground() {
    // final backgroundLayer = level.tileMap.getLayer('Background');
    // const tileSize = 64;
    // final numTileY = (game.size.y / tileSize).round();
    // final numTileX = (game.size.x / tileSize).round();

    // if (backgroundLayer != null) {
    //   final backgroundColor =
    //       backgroundLayer.properties.getValue('BackgroundColor');
    //   for (double y = 0; y < game.size.y / numTileY; y++) {
    //     for (double x = 0; x < numTileX; x++) {
    //       final backgroundTile = BackgroundTile(
    //         color: backgroundColor ?? 'Gray',
    //         position: Vector2(x * tileSize, y * tileSize),
    //       );

    //       add(backgroundTile);
    //     }
    //   }
    // }
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }
}
