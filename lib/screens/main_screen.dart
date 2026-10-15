import 'package:flutter/material.dart';

import '../models/character_model.dart';
import 'character_select_screen.dart';
import 'leaderboard_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff5bc9f8), Color(0xffe7f9ff)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _Cloud(x: .05, y: .13, scale: .9),
              const _Cloud(x: .70, y: .10, scale: .65),
              const _Cloud(x: .43, y: .30, scale: .55),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      const Text(
                        'NANA',
                        style: TextStyle(
                          fontSize: 54,
                          height: .95,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Color(0x550b4d78), blurRadius: 0, offset: Offset(3, 4)),
                          ],
                        ),
                      ),
                      const Text(
                        'PHIÊU LƯU KÝ',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 5,
                          color: Color(0xff164b75),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 210,
                        height: 210,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .42),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: .65), width: 3),
                        ),
                        child: Image.asset(
                          characters.first.assetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Bay, tránh ống,\nvà thu thập đồng xu sáng bóng!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff245777),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _MenuButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'CHƠI NGAY',
                        primary: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CharacterSelectScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _MenuButton(
                        icon: Icons.emoji_events_rounded,
                        label: 'TOP 10',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tap to flap • Coins +2 • Pipes +1',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff48748f),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Color(0x330b557e), blurRadius: 12, offset: Offset(0, 7)),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 31),
          label: Text(
            label,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: primary ? const Color(0xff2e9ce8) : Colors.white,
            foregroundColor: primary ? Colors.white : const Color(0xff23618b),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
        ),
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double x;
  final double y;
  final double scale;

  const _Cloud({required this.x, required this.y, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.sizeOf(context).width * x,
      top: MediaQuery.sizeOf(context).height * y,
      child: Transform.scale(
        scale: scale,
        child: const Icon(Icons.cloud_rounded, size: 90, color: Color(0xbfffffff)),
      ),
    );
  }
}
