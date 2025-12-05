import 'package:flutter/material.dart';
import '../../domain/entities/player_info.dart';

class PlayerListWidget extends StatelessWidget {
  final List<PlayerInfo> players;

  const PlayerListWidget({Key? key, required this.players}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const Center(child: Text('No hay jugadores aún'));

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, i) {
        final p = players[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: p.isHost ? Colors.amber : Theme.of(context).colorScheme.primary,
              child: p.isHost ? const Icon(Icons.star) : const Icon(Icons.person),
            ),
            title: Text(p.nickname, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Puntos: ${p.totalScore}'),
          ),
        );
      },
    );
  }
}
