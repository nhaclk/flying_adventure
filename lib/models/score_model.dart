class ScoreModel {
  final String name;
  final int score;

  const ScoreModel({
    required this.name,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
      };

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'PLAYER',
      score: (json['score'] as num?)?.toInt() ?? 0,
    );
  }
}
