class CharacterModel {
  final String id;
  final String name;
  final String assetPath;
  final String description;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.description,
  });
}

const characters = <CharacterModel>[
  CharacterModel(
    id: 'baby_duck',
    name: 'Na thúi',
    assetPath: 'assets/characters/character_01.png',
    description: 'Dễ thương và nhí nhảnh',
  ),
  CharacterModel(
    id: 'magic_girl',
    name: 'Ánh bụng bự',
    assetPath: 'assets/characters/character_02.png',
    description: 'Chậm chạm và lười',
  ),
  CharacterModel(
    id: 'ufo_boy',
    name: 'Mr. Muzik',
    assetPath: 'assets/characters/character_03.png',
    description: 'Quá ngầu và đẹp trai',
  ),
];
