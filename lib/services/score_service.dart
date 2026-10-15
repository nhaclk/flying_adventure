import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/score_model.dart';

/// Persistent local Top-10 leaderboard.
///
/// Uses SharedPreferences' cached API so every screen reads/writes the same
/// local store during the lifetime of the app.
class ScoreService {
  static const String _key = 'top_scores_v2';
  static const String _oldKey = 'top_scores_v1';

  Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  Future<List<ScoreModel>> getScores() async {
    final prefs = await _prefs();

    // Read the new key first. If this is an existing installation from the
    // previous project version, migrate the old leaderboard once.
    var raw = prefs.getStringList(_key);

    if (raw == null) {
      raw = prefs.getStringList(_oldKey);
      if (raw != null) {
        await prefs.setStringList(_key, raw);
      }
    }

    final scores = <ScoreModel>[];

    for (final item in raw ?? const <String>[]) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          scores.add(ScoreModel.fromJson(decoded));
        }
      } catch (_) {
        // Ignore a damaged leaderboard entry.
      }
    }

    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores.take(10).toList();
  }

  Future<bool> qualifiesForTop10(int score) async {
    if (score <= 0) return false;

    final scores = await getScores();

    return scores.length < 10 || score > scores.last.score;
  }

  Future<void> addScore(String name, int score) async {
    final prefs = await _prefs();
    final scores = await getScores();

    final cleanName = name.trim().isEmpty ? 'PLAYER' : name.trim();

    scores.add(
      ScoreModel(
        name: cleanName,
        score: score,
      ),
    );

    scores.sort((a, b) => b.score.compareTo(a.score));

    final top10 = scores.take(10).toList();
    final encoded = top10
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();

    final saved = await prefs.setStringList(_key, encoded);

    if (!saved) {
      throw Exception('Could not save leaderboard to local storage.');
    }

    // Verify the write immediately. This makes storage failures visible
    // instead of silently navigating to a leaderboard that looks unchanged.
    final verification = prefs.getStringList(_key) ?? const <String>[];

    if (verification.length != encoded.length) {
      throw Exception('Leaderboard verification failed.');
    }
  }
}
