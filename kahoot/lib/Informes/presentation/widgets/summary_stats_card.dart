import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../../domain/entities/player_result_detail.dart';

class SummaryStatsCard extends StatelessWidget {
  final PlayerResultDetail detail;

  const SummaryStatsCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    // Calculamos el tiempo promedio en segundos
    final avgSeconds = (detail.averageTimeMs / 1000).toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow, // Fondo Amarillo
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Puesto (Solo si existe / es Multiplayer)
          if (detail.rankingPosition != null && detail.rankingPosition! > 0) ...[
            Text(
              "Puesto #${detail.rankingPosition}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 16),
          ],

          // 2. Fila de Estadísticas (Puntos | Aciertos | Tiempo)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                value: "${detail.finalScore}",
                label: "Puntos",
                icon: Icons.star,
              ),
              _StatDivider(),
              _StatItem(
                value: "${detail.correctAnswers}/${detail.totalQuestions}",
                label: "Aciertos",
                icon: Icons.check_circle_outline,
              ),
              _StatDivider(),
              _StatItem(
                value: "${avgSeconds}s",
                label: "Tiempo",
                icon: Icons.timer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textBlack, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textBlack,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Colors.black12,
    );
  }
}