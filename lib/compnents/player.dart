import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:nextgrid/nextgrid.dart';

enum PlayerState { idle, running }

// enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<nextGrid>, KeyboardHandler {
  String character;
  Player({position, this.character = 'Ninja Frog'}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  // PlayerDirection playerDirection = PlayerDirection.none;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  // bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovermonet(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isleftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    final isNoneKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);

    horizontalMovement += isleftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    horizontalMovement += isNoneKeyPressed ? 0 : 0;
    // if (isleftKeyPressed && isRightKeyPressed) {
    //   playerDirection = PlayerDirection.none;
    // } else if (isleftKeyPressed) {
    //   playerDirection = PlayerDirection.left;
    //   print('A');
    // } else if (isRightKeyPressed) {
    //   playerDirection = PlayerDirection.right;
    // } else if (isNoneKeyPressed) {
    //   playerDirection = PlayerDirection.none;
    // }
    // if (isleftKeyPressed) {
    //   playerDirection = PlayerDirection.left;
    // } else if (isRightKeyPressed) {
    //   playerDirection = PlayerDirection.right;
    // } else if (isNoneKeyPressed) {
    //   playerDirection = PlayerDirection.none;
    // }
    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimation() {
    idleAnimation = _spriteAnimation('Idle', 11);

    runningAnimation = _spriteAnimation('Run', 12);

    //list of all animation
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation
    };
    // set current animation
    current = PlayerState.running;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
          amount: 12, stepTime: stepTime, textureSize: Vector2.all(32)),
    );
  }

  void _updatePlayerMovermonet(double dt) {
    // double dirX = 0.0;
    // switch (playerDirection) {
    //   case PlayerDirection.left:
    //     if (isFacingRight) {
    //       flipHorizontallyAroundCenter();
    //       isFacingRight = false;
    //     }
    //     current = PlayerState.running;
    //     dirX -= moveSpeed;
    //     break;

    //   case PlayerDirection.right:
    //     if (!isFacingRight) {
    //       flipHorizontallyAroundCenter();
    //       isFacingRight = true;
    //     }
    //     current = PlayerState.running;
    //     dirX += moveSpeed;
    //     break;

    //   case PlayerDirection.none:
    //     current = PlayerState.idle;
    //     break;
    //   default:
    // }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    current = playerState;
  }
}
