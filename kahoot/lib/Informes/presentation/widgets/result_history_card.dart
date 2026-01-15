import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../../domain/entities/result_summary.dart';
import '../../domain/entities/game_type.dart';

import '../pages/player_result_page.dart';
import '../pages/host_report_page.dart';

class ResultHistoryCard extends StatelessWidget {
  final ResultSummary summary;

  const ResultHistoryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    // CAMBIO: Usamos formato numérico estándar para evitar crash de Locale
    final dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(summary.completionDate);

    return Card(
      color: AppColors.primaryYellow, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: AppColors.shadowBlack,
      margin: EdgeInsets.zero, // El margen lo pone la lista
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Vital para evitar errores de layout
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.quiz, color: AppColors.textBlack),
                  ),
                  const SizedBox(width: 12),
                  // Usamos Flexible para evitar overflow horizontal
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textBlack,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87, 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black26),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Badge(type: summary.gameType),
                  Row(
                    children: [
                      if (summary.finalScore != null)
                        Text(
                          "${summary.finalScore} pts",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textBlack),
                        ),
                      if (summary.gameType == GameType.multiplayerPlayer && summary.rankingPosition != null) ...[
                         const SizedBox(width: 8),
                         Text(
                          "Puesto #${summary.rankingPosition}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textBlack),
                        ),
                      ]
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    if (summary.gameType.isHost) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => HostReportPage(id: summary.gameId, title: summary.title),
      ));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PlayerResultPage(
          id: summary.gameId,
          gameType: summary.gameType,
          title: summary.title,
        ),
      ));
    }
  }
}

class _Badge extends StatelessWidget {
  final GameType type;
  const _Badge({required this.type});

  @override
  Widget build(BuildContext context) {
    String text;
    IconData icon;
    
    switch(type) {
      case GameType.singleplayer:
        text = "Solitario";
        icon = Icons.person;
        break;
      case GameType.multiplayerHost:
        text = "Anfitrión";
        icon = Icons.grid_view;
        break;
      case GameType.multiplayerPlayer:
        text = "Jugador";
        icon = Icons.sports_esports;
        break;
      default:
        text = "Quiz";
        icon = Icons.question_mark;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textBlack),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
      ],
    );
  }
}