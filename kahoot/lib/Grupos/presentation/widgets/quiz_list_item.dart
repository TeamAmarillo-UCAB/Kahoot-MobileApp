import 'package:flutter/material.dart';

class QuizListItem extends StatelessWidget {
  final String title;
  final String availableUntil;
  final String status;
  final VoidCallback onTap;

  const QuizListItem({
    Key? key,
    required this.title,
    required this.availableUntil,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'COMPLETED';

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green.shade100 : Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.quiz,
            color: isCompleted ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            isCompleted ? "Completado" : "Disponible hasta: $availableUntil",
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
