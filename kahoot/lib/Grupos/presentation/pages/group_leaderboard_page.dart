import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_detail/group_detail_bloc.dart';
import '../bloc/group_detail/group_detail_state.dart';
import '../bloc/group_detail/group_detail_event.dart';

class GroupLeaderboardPage extends StatefulWidget {
  final String groupId;

  const GroupLeaderboardPage({Key? key, required this.groupId})
    : super(key: key);

  @override
  State<GroupLeaderboardPage> createState() => _GroupLeaderboardPageState();
}

class _GroupLeaderboardPageState extends State<GroupLeaderboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupDetailBloc>().add(
        LoadGroupLeaderboardEvent(groupId: widget.groupId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade200,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Volver", style: TextStyle(color: Colors.black)),
        ),
        leadingWidth: 80,
        title: const Text(
          "Ranking",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (state.leaderboard.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: Colors.amber.shade100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Aún no hay datos",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: state.leaderboard.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = state.leaderboard[index];
              final isTop3 = index < 3;

              Color cardColor = Colors.white;
              Color borderColor = Colors.grey.shade200;
              Color badgeColor = Colors.grey.shade100;
              Color textColor = Colors.grey.shade700;

              if (index == 0) {
                cardColor = Colors.amber.shade50;
                borderColor = Colors.amber.shade200;
                badgeColor = Colors.amber;
                textColor = Colors.amber.shade900;
              } else if (index == 1) {
                borderColor = Colors.grey.shade400;
                badgeColor = Colors.grey.shade300;
              } else if (index == 2) {
                borderColor = Colors.brown.shade200;
                badgeColor = Colors.brown.shade100;
              }

              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeColor,
                      border: isTop3
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                      boxShadow: isTop3
                          ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                          : null,
                    ),
                    child: Text(
                      "#${entry.position}",
                      style: TextStyle(
                        color: index == 0 ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    entry.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "${entry.completedQuizzes} quizzes",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      "${entry.totalPoints} pts",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
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
