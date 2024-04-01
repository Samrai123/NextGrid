import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:nextgrid/compnents/collision_block.dart';
import 'package:nextgrid/compnents/player_hitbox.dart';
import 'package:nextgrid/compnents/utilis.dart';
import 'package:nextgrid/nextgrid.dart';

enum PlayerState { idle, running, jumping, falling }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<nextGrid>, KeyboardHandler {
  String character;
  Player({position, this.character = 'Ninja Frog'}) : super(position: position);
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation jumpingAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 350;
  final double _terminalVelocity = 300;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox =
      PlayerHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);
  bool isOnGround = false;
  bool hasJumped = false;
  // bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimation();
    // debugMode = true;
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovermonet(dt);
    _checkHorizontalCollision();
    _applyGravity(dt);
    _checkVerticalCollision();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isleftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isleftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimation() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);

    //list of all animation
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation
    };
    // set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
          amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    //check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    //check if falling set to falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    if (velocity.y < 0) playerState = PlayerState.jumping;
    current = playerState;
  }

  void _checkHorizontalCollision() {
    for (final block in collisionBlocks) {
      // handle collision
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
        ;
      }
    }
  }

  void _updatePlayerMovermonet(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    // if (velocity.y > _gravity) isOnGround = false; //jumping in droping midair
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollision() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        //handle platforms.
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }
}
