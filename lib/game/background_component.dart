import 'package:flame/components.dart';

import 'flappy_game.dart';

class BackgroundComponent extends SpriteComponent
    with HasGameReference<FlappyGame> {
  BackgroundComponent() : super(priority: -100);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('game/background.png');
    _fit();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _fit();
  }

  void _fit() {
    position = Vector2.zero();
    size = game.size.clone();
    anchor = Anchor.topLeft;
  }
}
