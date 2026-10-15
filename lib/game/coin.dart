import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'flappy_game.dart';

class Coin extends SpriteComponent {
  bool collected = false;
  double _time = 0;
  final double startY;

  Coin({
    required Vector2 position,
    required Vector2 size,
  })  : startY = position.y,
        super(
          position: position,
          size: size,
          anchor: Anchor.center,
          priority: 25,
        );

  @override
  Future<void> onLoad() async {
    final game = findRootGame() as FlappyGame;
    sprite = await game.loadSprite('game/coin.png');
    add(
      CircleHitbox(
        radius: size.x * .38,
        collisionType: CollisionType.active,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final game = findRootGame() as FlappyGame;

    _time += dt;
    position.x -= game.pipeSpeed * dt;
    position.y = startY + math.sin(_time * 5) * 6;
    angle += dt * 3.5;

    final pulse = 1 + math.sin(_time * 8) * .05;
    scale = Vector2.all(pulse);

    if (position.x < -size.x) removeFromParent();
  }
}
