import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'flappy_game.dart';

class CloudComponent extends PositionComponent
    with HasGameReference<FlappyGame> {
  final double speed;
  final double cloudScale;

  CloudComponent({
    required Vector2 position,
    required this.speed,
    required this.cloudScale,
  }) : super(
          position: position,
          priority: -90,
        );

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= speed * dt;

    if (position.x < -220 * cloudScale) {
      position.x = game.size.x + 80 * cloudScale;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82);

    final r = 32 * cloudScale;

    canvas.drawCircle(
      Offset(
        0,
        12 * cloudScale,
      ),
      r,
      paint,
    );

    canvas.drawCircle(
      Offset(
        48 * cloudScale,
        0,
      ),
      r * 1.25,
      paint,
    );

    canvas.drawCircle(
      Offset(
        100 * cloudScale,
        15 * cloudScale,
      ),
      r * 0.95,
      paint,
    );

    canvas.drawOval(
      Rect.fromLTWH(
        -20 * cloudScale,
        12 * cloudScale,
        140 * cloudScale,
        45 * cloudScale,
      ),
      paint,
    );
  }
}