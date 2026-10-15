import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/flappy_game.dart';
import '../models/character_model.dart';
import '../services/score_service.dart';
import 'leaderboard_screen.dart';
import 'main_screen.dart';

class GameScreen extends StatefulWidget {
  final CharacterModel character;

  const GameScreen({super.key, required this.character});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final FlappyGame game;

  @override
  void initState() {
    super.initState();
    game = FlappyGame(character: widget.character, onGameOver: _handleGameOver);
  }

  Future<void> _handleGameOver(int score) async {
    final service = ScoreService();
    var qualifies = false;
    try {
      qualifies = await service.qualifiesForTop10(score);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kiểm tra bảng xếp hạng: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (!mounted) return;

    if (qualifies) {
      final name = await _showNameDialog(score);
      if (!mounted) return;

      // Always save the score BEFORE navigating to the leaderboard.
      // The name dialog returns the entered text when SAVE SCORE is pressed.
      if (name != null) {
        try {
          await service.addScore(name, score);
        } catch (error) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể lưu điểm: $error'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
      );
    } else {
      await _showGameOverDialog(score);
    }
  }

  Future<String?> _showNameDialog(int score) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Color(0xffffb800),
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(child: Text('NEW TOP 10!')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Điểm của bạn là $score điểm.',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 12,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Tên của bạn',
                  hintText: 'NGƯỜI CHƠI',
                  prefixIcon: const Icon(Icons.person_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim().isEmpty
                      ? 'PLAYER'
                      : controller.text.trim(),
                );
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('LƯU ĐIỂM'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGameOverDialog(int score) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Column(
            children: [
              Icon(Icons.cloud_off_rounded, size: 52, color: Color(0xff4d8bad)),
              SizedBox(height: 8),
              Text('GAME OVER', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Điểm của bạn',
                style: TextStyle(color: Color(0xff64879a)),
              ),
              const SizedBox(height: 4),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff1685cf),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowDirection: VerticalDirection.down,
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  game.restartGame();
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('CHƠI LẠI'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('THOÁT RA MENU'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<FlappyGame>(
            game: game,
            loadingBuilder: (_) => const ColoredBox(
              color: Color(0xff72d7ff),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _RoundButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () {
                          game.pauseGame();
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      ValueListenableBuilder<int>(
                        valueListenable: game.scoreNotifier,
                        builder: (_, score, _) {
                          return _ScorePill(score: score);
                        },
                      ),
                      const Spacer(),
                      ValueListenableBuilder<bool>(
                        valueListenable: game.pausedNotifier,
                        builder: (_, paused, _) {
                          return _RoundButton(
                            icon: paused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            onPressed: game.isGameOver
                                ? null
                                : game.togglePause,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<bool>(
                  valueListenable: game.pausedNotifier,
                  builder: (_, paused, _) {
                    if (!paused || game.isGameOver) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 90),
                      child: _PauseCard(onResume: game.resumeGame),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 22,
            child: SafeArea(
              top: false,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    'CHẠM BẤT KỲ NƠI NÀO ĐỂ VẬT BAY',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .9),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    game.pauseGame();
    super.dispose();
  }
}

class _ScorePill extends StatelessWidget {
  final int score;

  const _ScorePill({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x300b557e),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xffffbd17), size: 25),
          const SizedBox(width: 7),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Color(0xff1c5275),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .92),
      shape: const CircleBorder(),
      elevation: 5,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xff245d7d)),
        iconSize: 25,
      ),
    );
  }
}

class _PauseCard extends StatelessWidget {
  final VoidCallback onResume;

  const _PauseCard({required this.onResume});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330b557e),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.pause_circle_filled_rounded,
            size: 58,
            color: Color(0xff2e9ce8),
          ),
          const SizedBox(height: 8),
          const Text(
            'PAUSED',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xff1c5275),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'RESUME',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
