import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../models/character_model.dart';
import '../services/audio_service.dart';
import 'flappy_game.dart';
import 'coin.dart';
import 'pipe_pair.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameReference<FlappyGame> {
  final CharacterModel character;

  double velocityY = 0;
  bool alive = true;
  double _time = 0;

  static const gravity = 980.0;
  static const flapStrength = -390.0;

  Player({
    required this.character,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
          priority: 30,
        );

  @override
  Future<void> onLoad() async {
    final path = character.assetPath.replaceFirst('assets/', '');
    sprite = await game.loadSprite(path);

    add(
      CircleHitbox(
        radius: math.min(size.x, size.y) * .30,
        position: Vector2(size.x * .02, size.y * .03),
        collisionType: CollisionType.active,
      ),
    );
  }

  void flap() {
    if (!alive || game.isGameOver) return;
    velocityY = flapStrength;
    AudioService.playSfx('flap.wav');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!alive || game.isGameOver) return;

    _time += dt;
    velocityY += gravity * dt;
    position.y += velocityY * dt;

    final targetAngle = (velocityY / 650).clamp(-0.45, 0.75).toDouble();
    angle += (targetAngle - angle) * math.min(1, dt * 8);

    // Small hover motion while moving upward/downward.
    final bob = math.sin(_time * 8) * .015;
    scale = Vector2.all(1 + bob);

    final topLimit = size.y * .38;
    final bottomLimit = game.size.y - FlappyGame.groundHeight - size.y * .38;
    if (position.y < topLimit) {
      position.y = topLimit;
      velocityY = 0;
    }
    if (position.y > bottomLimit) {
      game.gameOver();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PipePart) {
      game.gameOver();
      return;
    }

    if (other is Coin && !other.collected) {
      other.collected = true;
      game.collectCoin(other);
    }
  }
}
