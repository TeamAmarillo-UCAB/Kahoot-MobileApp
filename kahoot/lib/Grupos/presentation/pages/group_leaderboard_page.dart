import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_detail/group_detail_bloc.dart';
import '../bloc/group_detail/group_detail_state.dart';

class GroupLeaderboardPage extends StatelessWidget {
  final String groupId;

  const GroupLeaderboardPage({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Volver", style: TextStyle(color: Colors.black)),
        ),
        leadingWidth: 80,
        title: Text("Ranking del Grupo", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          if (state.leaderboard.isEmpty)
            return Center(child: Text("Aún no hay datos para el ranking"));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: state.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = state.leaderboard[index];
              final isTop3 = index < 3;

              return Card(
                color: isTop3 ? Colors.amber.shade50 : Colors.white,
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isTop3 ? Colors.amber : Colors.grey.shade300,
                    ),
                    child: Text(
                      "#${entry.position}",
                      style: TextStyle(
                        color: isTop3 ? Colors.black : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    entry.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${entry.completedQuizzes} kahoots completados",
                  ),
                  trailing: Text(
                    "${entry.totalPoints} pts",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
