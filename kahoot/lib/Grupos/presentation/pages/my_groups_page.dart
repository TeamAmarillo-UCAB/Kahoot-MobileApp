import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kahoot/Grupos/application/usecases/get_group_leaderboard.dart';

import '../../../../Grupos/domain/entities/group.dart';
import '../../../../Grupos/domain/repositories/group_repository.dart';

import '../bloc/group_list/group_list_bloc.dart';
import '../bloc/group_list/group_list_state.dart';
import '../bloc/group_list/group_list_event.dart';

import '../bloc/group_detail/group_detail_bloc.dart';
import 'group_detail_page.dart';

import '../../../../Grupos/application/usecases/get_group_details.dart';
import '../../../../Grupos/application/usecases/generate_invitation.dart';
import '../../../../Grupos/application/usecases/remove_member.dart';
import '../../../../Grupos/application/usecases/delete_group.dart';
import '../../../../Grupos/application/usecases/edit_group.dart';

class MyGroupsPage extends StatelessWidget {
  const MyGroupsPage({Key? key}) : super(key: key);
  final String _currentUserId = "397b9a84-f851-417e-91da-fdfc271b1a81";
  //final String _currentUserId = "f99e03b5-b87a-47fb-a966-34d03b6d63f4";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Grupos de Estudio"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<GroupListBloc, GroupListState>(
        listener: (context, state) {
          // Manejo de errores (SnackBar)
          if (state is GroupListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GroupListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroupListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text("Error: ${state.message}"),
                  TextButton(
                    onPressed: () =>
                        context.read<GroupListBloc>().add(LoadGroupsEvent()),
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            );
          }

          if (state is GroupListLoaded) {
            final List<Group> groups = state.groups;

            if (groups.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return _buildGroupCard(context, group);
              },
            );
          }

          if (state is GroupListInitial) {
            context.read<GroupListBloc>().add(LoadGroupsEvent());
            return const Center(child: CircularProgressIndicator());
          }

          return const SizedBox.shrink();
        },
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: "btnCreate",
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showCreateGroupDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No tienes grupos aún."),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showCreateGroupDialog(context),
            child: const Text("Crear mi primer grupo"),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Group group) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            group.name.isNotEmpty
                ? group.name.substring(0, 1).toUpperCase()
                : "?",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // 'role' y 'memberCount'
        subtitle: Text(
          "${group.role} • ${group.memberCount} miembros",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: () {
          final repository = context.read<GroupRepository>();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return BlocProvider(
                  create: (ctx) => GroupDetailBloc(
                    getGroupDetails: GetGroupDetails(repository),
                    generateInvitation: GenerateInvitation(repository),
                    removeMember: RemoveMember(repository),
                    deleteGroup: DeleteGroup(repository),
                    editGroup: EditGroup(repository),
                    getGroupLeaderboard: GetGroupLeaderboard(repository),
                    currentUserId: _currentUserId,
                  ),
                  child: GroupDetailPage(group: group),
                );
              },
            ),
          ).then((_) {
            context.read<GroupListBloc>().add(LoadGroupsEvent());
          });
        },
      ),
    );
  }

  // --- DIALOG DE CREAR GRUPO ---

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nuevo Grupo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Descripción (Opcional)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // Evento con argumentos posicionales (definido así en GroupListEvent)
                context.read<GroupListBloc>().add(
                  CreateGroupEvent(nameController.text, descController.text),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }
}
