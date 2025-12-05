import 'package:flutter/material.dart';
import '../../domain/entities/scoreboard_entry.dart';

class ScoreboardWidget extends StatelessWidget {
  final List<ScoreboardEntry> entries;

  const ScoreboardWidget({Key? key, required this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('Sin puntuaciones'));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final e = entries[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(child: Text('${e.position}')),
            title: Text(e.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Puntos: ${e.totalPoints}'),
          ),
        );
      },
    );
  }
}
