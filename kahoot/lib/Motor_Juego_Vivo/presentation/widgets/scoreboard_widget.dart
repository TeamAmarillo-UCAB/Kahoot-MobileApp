import 'package:flutter/material.dart';
import '../../domain/entities/scoreboard_entry.dart';

class ScoreboardWidget extends StatelessWidget {
  final List<ScoreboardEntry> entries;

  const ScoreboardWidget({Key? key, required this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Center(child: Text('Sin puntuaciones', style: TextStyle(color: Colors.white70)));

    final cardColor = Colors.grey.shade900;
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final e = entries[i];
        return Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: e.position <= 3 ? Colors.amber.shade400 : Theme.of(context).colorScheme.primary,
                child: Text('${e.position}', style: TextStyle(color: e.position <= 3 ? Colors.black : Colors.white, fontWeight: FontWeight.bold))),
            title: Text(e.nickname, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text('Puntos: ${e.totalPoints}', style: const TextStyle(color: Colors.white70)),
          ),
        );
      },
    );
  }
}