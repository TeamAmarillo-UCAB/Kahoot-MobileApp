import 'package:flutter/material.dart';
import '../../domain/entities/player_info.dart';

class PlayerListWidget extends StatelessWidget {
  final List<PlayerInfo> players;

  const PlayerListWidget({Key? key, required this.players}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const Center(child: Text('No hay jugadores aún', style: TextStyle(color: Colors.white70)));

    final cardColor = Colors.grey.shade900; // Color de tarjeta más oscuro

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, i) {
        final p = players[i];
        return Card(
          color: cardColor, // Usamos el color oscuro
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: p.isHost ? Colors.amber.shade400 : Theme.of(context).colorScheme.primary,
              child: p.isHost ? const Icon(Icons.star, color: Colors.black) : const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(p.nickname, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('Puntos: ${p.totalScore}', style: const TextStyle(color: Colors.white70)),
          ),
        );
      },
    );
  }
}