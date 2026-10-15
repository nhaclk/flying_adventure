import 'dart:async';
import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/character_model.dart';
import '../services/audio_service.dart';
import 'background_component.dart';
import 'cloud_component.dart';
import 'coin.dart';
import 'game_constants.dart';
import 'ground_component.dart';
import 'pipe_pair.dart';
import 'player.dart';

class FlappyGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  final CharacterModel character;
  final Future<void> Function(int score) onGameOver;

  final Random _random = Random();

  late Player player;

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> pausedNotifier = ValueNotifier<bool>(false);

  int score = 0;
  bool isGameOver = false;

  double spawnTimer = 0;
  double pipeSpeed = 205;
  double pipeInterval = 1.95;
  double gapHeight = 245;

  static const double groundHeight = 120;

  FlappyGame({required this.character, required this.onGameOver}) {
    // Flame normally expects assets under assets/images/. This project keeps
    // game art under assets/game and character art under assets/characters.
    images.prefix = 'assets/';
  }

  @override
  Color backgroundColor() => gameSky;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioService.initialize();

    await images.loadAll([
      'game/background.png',
      'game/ground.png',
      'game/pipe.png',
      'game/coin.png',
      character.assetPath.replaceFirst('assets/', ''),
    ]);

    add(BackgroundComponent());

    add(
      CloudComponent(
        position: Vector2(size.x * .08, size.y * .16),
        speed: 16,
        cloudScale: .85,
      ),
    );
    add(
      CloudComponent(
        position: Vector2(size.x * .68, size.y * .28),
        speed: 22,
        cloudScale: .62,
      ),
    );
    add(
      CloudComponent(
        position: Vector2(size.x * .42, size.y * .48),
        speed: 13,
        cloudScale: .50,
      ),
    );

    add(GroundComponent());
    _createPlayer();
    await AudioService.startMusic();
  }

  void _createPlayer() {
    final playerSize = character.id == 'baby_duck'
        ? Vector2(104, 92)
        : Vector2.all(98);

    player = Player(
      character: character,
      position: Vector2(size.x * .28, size.y * .48),
      size: playerSize,
    );
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || pausedNotifier.value) return;

    spawnTimer += dt;
    if (spawnTimer >= pipeInterval) {
      spawnTimer = 0;
      _spawnPipe();
    }
  }

  void _spawnPipe() {
    final playableHeight = size.y - groundHeight;
    final minGapY = gapHeight / 2 + 75;
    final maxGapY = playableHeight - gapHeight / 2 - 75;
    final gapY = minGapY + _random.nextDouble() * (maxGapY - minGapY);

    final pipeX = size.x + 70;
    add(PipePair(x: pipeX, gapY: gapY, gapHeight: gapHeight));

    // Random coins appear in the pipe gap. Some pipes have no coin, keeping
    // collection optional rather than mandatory.
    if (_random.nextDouble() < .78) {
      final coinY = gapY + (_random.nextDouble() - .5) * (gapHeight * .58);
      final coinX = pipeX + 120 + _random.nextDouble() * 80;
      add(Coin(position: Vector2(coinX, coinY), size: Vector2.all(48)));
    }
  }

  void flap() {
    if (isGameOver || pausedNotifier.value) return;
    player.flap();
  }

  @override
  void onTapDown(TapDownEvent event) {
    flap();
  }

  void addPipeScore() {
    if (isGameOver) return;
    score += 1;
    scoreNotifier.value = score;
    _updateDifficulty();
    AudioService.playSfx('score.wav');
  }

  void collectCoin(Coin coin) {
    if (isGameOver || coin.isRemoved) return;
    score += 2;
    scoreNotifier.value = score;
    _updateDifficulty();
    coin.removeFromParent();
  }

  void _updateDifficulty() {
    if (score >= 60) {
      pipeSpeed = 285;
      gapHeight = 195;
      pipeInterval = 1.60;
    } else if (score >= 40) {
      pipeSpeed = 265;
      gapHeight = 205;
      pipeInterval = 1.68;
    } else if (score >= 25) {
      pipeSpeed = 245;
      gapHeight = 220;
      pipeInterval = 1.78;
    } else if (score >= 10) {
      pipeSpeed = 225;
      gapHeight = 232;
      pipeInterval = 1.88;
    } else {
      pipeSpeed = 205;
      gapHeight = 245;
      pipeInterval = 1.95;
    }
  }

  Future<void> gameOver() async {
    if (isGameOver) return;

    isGameOver = true;
    player.alive = false;
    pauseEngine();
    pausedNotifier.value = true;

    unawaited(AudioService.stopMusic());
    unawaited(AudioService.playSfx('hit.wav'));

    await onGameOver(score);
  }

  void pauseGame() {
    if (isGameOver || pausedNotifier.value) return;
    pausedNotifier.value = true;
    pauseEngine();
    AudioService.pauseMusic();
  }

  void resumeGame() {
    if (isGameOver || !pausedNotifier.value) return;
    pausedNotifier.value = false;
    resumeEngine();
    AudioService.resumeMusic();
  }

  void togglePause() {
    if (pausedNotifier.value) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  void restartGame() {
    children.whereType<PipePair>().toList().forEach(remove);
    children.whereType<Coin>().toList().forEach(remove);

    player.removeFromParent();

    score = 0;
    scoreNotifier.value = 0;
    isGameOver = false;
    pausedNotifier.value = false;
    spawnTimer = .8;
    _updateDifficulty();

    _createPlayer();
    resumeEngine();
    AudioService.startMusic();
  }

  @override
  void onRemove() {
    scoreNotifier.dispose();
    pausedNotifier.dispose();
    AudioService.stopMusic();
    super.onRemove();
  }
}
