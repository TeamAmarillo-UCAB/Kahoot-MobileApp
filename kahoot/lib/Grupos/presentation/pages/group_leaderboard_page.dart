import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_detail/group_detail_bloc.dart';
import '../bloc/group_detail/group_detail_state.dart';
import '../bloc/group_detail/group_detail_event.dart'; // Importar eventos

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
    // DISPARAR EL EVENTO AL CARGAR LA PANTALLA
    // Usamos addPostFrameCallback para asegurar que el contexto esté listo,
    // aunque en initState suele funcionar directo con context.read.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupDetailBloc>().add(
        LoadGroupLeaderboardEvent(groupId: widget.groupId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Volver", style: TextStyle(color: Colors.black)),
        ),
        leadingWidth: 80,
        title: const Text(
          "Ranking del Grupo",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          // CASO 1: Cargando (Muestra solo el spinner)
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // CASO 2: No está cargando y la lista está vacía (Muestra "Sin datos")
          if (state.leaderboard.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 60,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sin datos",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // CASO 3: Hay datos (Muestra la lista)
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = state.leaderboard[index];
              final isTop3 = index < 3;

              return Card(
                color: isTop3 ? Colors.amber.shade50 : Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${entry.completedQuizzes} kahoots completados",
                  ),
                  trailing: Text(
                    "${entry.totalPoints} pts",
                    style: const TextStyle(
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
