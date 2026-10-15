import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/character_model.dart';
import 'game_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  int selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: .78,
      initialPage: selectedIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = characters[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xffeefaff),
      appBar: AppBar(
        title: const Text('CHỌN NGƯỜI ĐỂ BAY NÈ'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                'Chọn nhân vật và bắt đầu chuyến bay của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff4b7086),
                ),
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: const {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => selectedIndex = index),
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return _CharacterCard(
                      character: character,
                      selected: selectedIndex == index,
                      onTap: () => setState(() => selectedIndex = index),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      '${selected.name} • ${selected.description}',
                      key: ValueKey(selected.id),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff1c587c),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(character: selected),
                          ),
                        );
                      },
                      icon: const Icon(Icons.flight_takeoff_rounded, size: 28),
                      label: const Text(
                        'BAY THÔI NÈ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2e9ce8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final bool selected;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.character,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.fromLTRB(8, selected ? 8 : 24, 8, selected ? 8 : 24),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: selected
                  ? const [Color(0xffffffff), Color(0xffe2f6ff)]
                  : const [Color(0xfff8fdff), Color(0xffeaf8fd)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected
                  ? const Color(0xff2e9ce8)
                  : const Color(0xffc6e5f2),
              width: selected ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0x332e9ce8)
                    : const Color(0x180b557e),
                blurRadius: selected ? 22 : 10,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Hero(
                    tag: 'character_${character.id}',
                    child: Image.asset(
                      character.assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        character.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff214f6b),
                        ),
                      ),
                    ),
                    if (selected)
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xff2e9ce8),
                        child: Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
