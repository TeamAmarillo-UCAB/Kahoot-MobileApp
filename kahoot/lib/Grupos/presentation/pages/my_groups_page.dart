import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Grupos/infrastructure/datasources/group_datasource_impl.dart';
import '../../../../Grupos/infrastructure/repositories/group_repository_impl.dart';

import '../../../../Grupos/domain/entities/group.dart';
import '../../../../Grupos/domain/repositories/group_repository.dart';
import '../../../../Grupos/application/usecases/get_user_groups.dart';
import '../../../../Grupos/application/usecases/create_group.dart';
import '../../../../Grupos/application/usecases/join_group.dart';
import '../../../../Grupos/application/usecases/get_group_leaderboard.dart';
import '../../../../Grupos/application/usecases/get_group_details.dart';
import '../../../../Grupos/application/usecases/generate_invitation.dart';
import '../../../../Grupos/application/usecases/remove_member.dart';
import '../../../../Grupos/application/usecases/delete_group.dart';
import '../../../../Grupos/application/usecases/edit_group.dart';

import '../../../../Gestion_usuarios/infrastructure/datasource/user_datasource_impl.dart';
import '../../../../Gestion_usuarios/infrastructure/repositories/user_repository_impl.dart';
import '../../../../Gestion_usuarios/application/usecases/get_user_by_id.dart';

import '../bloc/group_list/group_list_bloc.dart';
import '../bloc/group_list/group_list_state.dart';
import '../bloc/group_list/group_list_event.dart';
import '../bloc/group_detail/group_detail_bloc.dart';
import 'group_detail_page.dart';

class MyGroupsPage extends StatelessWidget {
  final String? invitationToken;

  const MyGroupsPage({Key? key, this.invitationToken}) : super(key: key);

  final String _currentUserId = "c5b09c21-bcfd-492e-9f3b-d7089074185d";

  @override
  Widget build(BuildContext context) {
    final datasource = GroupDatasourceImpl();
    final repository = GroupRepositoryImpl(datasource: datasource);

    final userDatasource = UserDatasourceImpl();
    final userRepository = UserRepositoryImpl(datasource: userDatasource);

    return RepositoryProvider<GroupRepository>.value(
      value: repository,
      child: BlocProvider(
        create: (context) {
          final bloc = GroupListBloc(
            getUserGroups: GetUserGroups(repository),
            createGroup: CreateGroup(repository),
            joinGroup: JoinGroup(repository),
            currentUserId: _currentUserId,
          );

          bloc.add(LoadGroupsEvent());

          if (invitationToken != null) {
            bloc.add(JoinGroupEvent(token: invitationToken!));
          }

          return bloc;
        },
        child: _MyGroupsView(
          currentUserId: _currentUserId,
          userRepository: userRepository,
        ),
      ),
    );
  }
}

class _MyGroupsView extends StatelessWidget {
  final String currentUserId;
  final UserRepositoryImpl userRepository;

  const _MyGroupsView({
    Key? key,
    required this.currentUserId,
    required this.userRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A240C),
      appBar: AppBar(
        title: const Text(
          "Mis Grupos",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocConsumer<GroupListBloc, GroupListState>(
        listener: (context, state) {
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
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (state is GroupListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Ocurrió un error",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GroupListBloc>().add(LoadGroupsEvent()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final group = groups[index];
                return _buildGroupCard(context, group);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btnCreate",
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 4,
        onPressed: () => _showCreateGroupDialog(context),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.group_off_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No tienes grupos aún",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Crea uno nuevo para empezar a estudiar",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateGroupDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Crear mi primer grupo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Group group) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade300,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
                      currentUserId: currentUserId,
                      getUserById: GetUserById(userRepository),
                    ),
                    child: GroupDetailPage(group: group),
                  );
                },
              ),
            ).then((_) {
              if (context.mounted) {
                context.read<GroupListBloc>().add(LoadGroupsEvent());
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    group.name.isNotEmpty
                        ? group.name.substring(0, 1).toUpperCase()
                        : "?",
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${group.memberCount} miembros",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              group.role,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (group.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          group.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Nuevo Grupo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              cursorColor: Colors.amber,
              decoration: const InputDecoration(
                labelText: "Nombre",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              cursorColor: Colors.amber,
              decoration: const InputDecoration(
                labelText: "Descripción (Opcional)",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<GroupListBloc>().add(
                  CreateGroupEvent(nameController.text, descController.text),
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }
}
