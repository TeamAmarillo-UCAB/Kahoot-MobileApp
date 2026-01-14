import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_detail/group_detail_bloc.dart';
import '../bloc/group_detail/group_detail_state.dart';
import '../bloc/group_detail/group_detail_event.dart';

class ManageMembersPage extends StatelessWidget {
  final String groupId;

  const ManageMembersPage({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Volver", style: TextStyle(color: Colors.black)),
        ),
        leadingWidth: 80,
        title: Text(
          "Gestionar miembros",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<GroupDetailBloc, GroupDetailState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: state.members.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final member = state.members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(member.name[0].toUpperCase()),
                      ),
                      title: Text(member.name),
                      subtitle: Text(member.role),
                      trailing: member.role != 'ADMIN'
                          ? IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _showRemoveMemberDialog(
                                context,
                                member.userId,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => context.read<GroupDetailBloc>().add(
                    GenerateInvitationEvent(groupId),
                  ),
                  icon: Icon(Icons.add),
                  label: Text("Invitar miembros"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, String memberId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Eliminar miembro"),
        content: Text(
          "¿Estás seguro de que quieres eliminar a este miembro del grupo?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              context.read<GroupDetailBloc>().add(
                RemoveMemberEvent(memberId: memberId),
              );
              Navigator.pop(context);
            },
            child: Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
