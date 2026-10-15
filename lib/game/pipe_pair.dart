import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'flappy_game.dart';

class PipePair extends PositionComponent
    with HasGameReference<FlappyGame> {
  final double gapY;
  final double gapHeight;
  bool scored = false;

  PipePair({
    required double x,
    required this.gapY,
    required this.gapHeight,
  }) : super(
          position: Vector2(x, 0),
          anchor: Anchor.topLeft,
          priority: 20,
        );

  @override
  Future<void> onLoad() async {
    const pipeWidth = 82.0;
    final topHeight = (gapY - gapHeight / 2).clamp(40.0, game.size.y).toDouble();
    final bottomY = gapY + gapHeight / 2;
    final bottomHeight =
        (game.size.y - bottomY - FlappyGame.groundHeight).clamp(40.0, game.size.y).toDouble();

    add(
      PipePart(
        position: Vector2.zero(),
        size: Vector2(pipeWidth, topHeight),
      ),
    );

    add(
      PipePart(
        position: Vector2(0, bottomY),
        size: Vector2(pipeWidth, bottomHeight),
        flipped: true,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= game.pipeSpeed * dt;

    if (!scored && position.x + 82 < game.player.position.x) {
      scored = true;
      game.addPipeScore();
    }

    if (position.x < -120) removeFromParent();
  }
}

class PipePart extends SpriteComponent {
  final bool flipped;

  PipePart({
    required Vector2 position,
    required Vector2 size,
    this.flipped = false,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    final game = findRootGame() as FlappyGame;
    sprite = await game.loadSprite('game/pipe.png');
    if (flipped) flipVerticallyAroundCenter();

    add(
      RectangleHitbox(
        collisionType: CollisionType.active,
      ),
    );
  }
}
