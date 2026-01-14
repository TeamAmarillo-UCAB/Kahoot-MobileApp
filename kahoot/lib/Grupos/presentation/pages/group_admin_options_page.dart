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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Volver", style: TextStyle(color: Colors.black)),
        ),
        leadingWidth: 80,
        title: const Text(
          "Gestionar grupo",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _AdminOptionTile(
            icon: Icons.people_rounded,
            title: "Gestionar miembros",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManageMembersPage(groupId: groupId),
              ),
            ),
          ),
          _AdminOptionTile(
            icon: Icons.edit_rounded,
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
          const SizedBox(height: 20),
          _AdminOptionTile(
            icon: Icons.delete_outline_rounded,
            title: "Eliminar grupo",
            textColor: Colors.red,
            iconColor: Colors.red,
            bgColor: Colors.red.shade50,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("¿Quieres eliminar este grupo?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GroupDetailBloc>().add(DeleteGroupEvent(groupId));
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Sí, eliminar"),
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
  final Color? bgColor;

  const _AdminOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor = Colors.black,
    this.iconColor = Colors.black,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor ?? Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: bgColor != null ? iconColor : Colors.amber.shade900,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }
}
