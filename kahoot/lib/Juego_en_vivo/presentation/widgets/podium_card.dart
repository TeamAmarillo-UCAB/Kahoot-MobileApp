import 'package:flutter/material.dart';

class PodiumCard extends StatelessWidget {
  final String nickname;
  final int score;
  final int rank;
  final bool isCurrentUser;

  const PodiumCard({
    super.key,
    required this.nickname,
    required this.score,
    required this.rank,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color rankColor = _getRankColor(rank);
    final double heightFactor = _getHeightFactor(rank);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (rank == 1)
          const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
        Text(
          nickname,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.bold,
            color: isCurrentUser ? Colors.amber : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: rankColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: [
              if (isCurrentUser)
                const BoxShadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.black12,
          child: Text(
            '$score',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[400]!;
      default:
        return Colors.blueGrey[200]!;
    }
  }

  double _getHeightFactor(int rank) {
    switch (rank) {
      case 1:
        return 1.5;
      case 2:
        return 1.2;
      case 3:
        return 1.0;
      default:
        return 0.8;
    }
  }
}
