import 'package:flame/components.dart';

import 'flappy_game.dart';

class GroundComponent extends SpriteComponent
    with HasGameReference<FlappyGame> {
  GroundComponent() : super(priority: 50);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('game/ground.png');
    _fit();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _fit();
  }

  void _fit() {
    size = Vector2(game.size.x, 120);
    position = Vector2(0, game.size.y - size.y);
    anchor = Anchor.topLeft;
  }
}
