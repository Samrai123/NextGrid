import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:nextgrid/compnents/checkpoint.dart';
import 'package:nextgrid/compnents/collision_block.dart';
import 'package:nextgrid/compnents/custom_hitbox.dart';
import 'package:nextgrid/compnents/fruit.dart';
import 'package:nextgrid/compnents/saw.dart';
import 'package:nextgrid/compnents/utilis.dart';
import 'package:nextgrid/nextgrid.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<nextGrid>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({position, this.character = 'Ninja Frog'}) : super(position: position);
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  double fixedDeltaTime = 1 / 60;
  double accumlatedTime = 0;

  double horizontalMovement = 0.0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox =
      CustomHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachCheckpoint = false;
  // bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimation();
    // debugMode = true;
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumlatedTime += dt;
    while (accumlatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovermonet(fixedDeltaTime);
        _checkHorizontalCollision();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollision();
      }
      accumlatedTime -= fixedDeltaTime;
    }

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

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachCheckpoint) {
      if (other is Fruit) other.colliedWithPlayer();
      if (other is Saw) _respawn();
      if (other is Checkpoint) _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimation() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7);
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    //list of all animation
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
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

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
          amount: amount, stepTime: stepTime, textureSize: Vector2.all(96)),
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

  void _respawn() {
    const hitDuration = Duration(milliseconds: 350);
    const apperaingDuration = Duration(milliseconds: 350);
    const cantMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;
    Future.delayed(hitDuration, () {
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      current = PlayerState.appearing;

      Future.delayed(apperaingDuration, () {
        velocity = Vector2.zero();
        position = startingPosition;
        _updatePlayerState();
        Future.delayed(cantMoveDuration, () => gotHit = false);
      });
    });
    // position = startingPosition;
  }

  void _reachedCheckpoint() {
    reachCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    const reachedCheckpoint = Duration(milliseconds: 350);
    Future.delayed(reachedCheckpoint, () {
      reachCheckpoint = false;
      position = Vector2.all(-640);
      const waitToChangeDuration = Duration(seconds: 3);
      Future.delayed(waitToChangeDuration, () {
        game.loadNext();
      });
    });
  }
  // void _respawn() async {
  //   const canMoveDuration = Duration(milliseconds: 400);
  //   gotHit = true;
  //   current = PlayerState.hit;

  //   await animationTicker?.completed;
  //   animationTicker?.reset();

  //   scale.x = 1;
  //   position = startingPosition - Vector2.all(32);
  //   current = PlayerState.appearing;

  //   await animationTicker?.completed;
  //   animationTicker?.reset();

  //   velocity = Vector2.zero();
  //   position = startingPosition;
  //   _updatePlayerState();
  //   Future.delayed(canMoveDuration, () => gotHit = false);
  // }
}
