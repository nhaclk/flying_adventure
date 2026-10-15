import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/score_model.dart';

class ScoreService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<ScoreModel>> getScores() async {
    final rows = await _client
        .from('scores')
        .select('name, score')
        .order('score', ascending: false)
        .order('created_at')
        .order('id')
        .limit(10);

    return rows.map((row) => ScoreModel.fromJson(row)).toList();
  }

  Future<bool> qualifiesForTop10(int score) async {
    if (score <= 0) return false;

    final scores = await getScores();
    return scores.length < 10 || score > scores.last.score;
  }

  Future<bool> addScore(String name, int score) async {
    final cleanName = name.trim().isEmpty ? 'PLAYER' : name.trim();
    final result = await _client.rpc(
      'submit_score',
      params: {'player_name': cleanName, 'player_score': score},
    );

    if (result is! bool) {
      throw StateError('The score service returned an invalid response.');
    }

    return result;
  }
}
