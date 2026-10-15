import 'package:flutter/material.dart';

import '../models/score_model.dart';
import '../services/score_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ScoreService service = ScoreService();
  List<ScoreModel> scores = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await service.getScores();
    if (!mounted) return;
    setState(() {
      scores = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeefaff),
      appBar: AppBar(
        title: const Text('TOP 10'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final score = index < scores.length ? scores[index] : null;
                  return _ScoreRow(rank: index + 1, score: score);
                },
              ),
            ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int rank;
  final ScoreModel? score;

  const _ScoreRow({required this.rank, required this.score});

  @override
  Widget build(BuildContext context) {
    final filled = score != null;
    final medal = switch (rank) {
      1 => const Color(0xffffc83d),
      2 => const Color(0xffb7c3cf),
      3 => const Color(0xffd9945a),
      _ => const Color(0xff2e9ce8),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffd7edf5)),
        boxShadow: const [
          BoxShadow(color: Color(0x100b557e), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: CircleAvatar(
          radius: 23,
          backgroundColor: filled ? medal : const Color(0xffeaf5fa),
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: filled ? Colors.white : const Color(0xff7c9aae),
            ),
          ),
        ),
        title: Text(
          filled ? score!.name : '—',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xff214f6b)),
        ),
        subtitle: Text(filled ? 'Great flight!' : 'Open spot'),
        trailing: Text(
          filled ? '${score!.score}' : '0',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: filled ? const Color(0xff1685cf) : const Color(0xff9bb2bf),
          ),
        ),
      ),
    );
  }
}
