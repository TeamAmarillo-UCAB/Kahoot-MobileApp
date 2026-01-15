import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'manage_members_page.dart';
import 'edit_group_page.dart';
import '../bloc/group_detail/group_detail_bloc.dart';
import '../bloc/group_detail/group_detail_event.dart';

class GroupAdminOptionsPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  const GroupAdminOptionsPage({required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Volver", style: TextStyle(color: Colors.black)),
        ),
        leadingWidth: 80,
        title: Text("Gestionar grupo", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _AdminOptionTile(
            icon: Icons.people,
            title: "Gestionar miembros",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManageMembersPage(groupId: groupId),
              ),
            ),
          ),
          _AdminOptionTile(
            icon: Icons.edit,
            title: "Editar grupo",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditGroupPage(
                  groupId: groupId,
                  currentName: groupName,
                  currentDescription: '',
                ),
              ),
            ),
          ),
          _AdminOptionTile(
            icon: Icons.delete_outline,
            title: "Eliminar grupo",
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showDeleteConfirmDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("¿Quieres eliminar este grupo?"),
        content: Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              context.read<GroupDetailBloc>().add(DeleteGroupEvent(groupId));
              Navigator.pop(context); // Cierra dialogo
              Navigator.pop(context); // Cierra admin options
              Navigator.pop(context); // Cierra detail (Vuelve a Mis Grupos)
            },
            child: Text("Sí, eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AdminOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;

  const _AdminOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor = Colors.black,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
