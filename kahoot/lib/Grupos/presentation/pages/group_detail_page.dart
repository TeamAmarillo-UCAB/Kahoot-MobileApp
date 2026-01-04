import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// BloC y Eventos
import '../bloc/group_detail/group_detail_bloc.dart';
import '../bloc/group_detail/group_detail_event.dart';
import '../bloc/group_detail/group_detail_state.dart';

// Entidades
import '../../domain/entities/group.dart';

// Widgets y Páginas
import 'invite_success_dialog.dart'; // Asegúrate de importar el dialog que acabamos de crear

class GroupDetailPage extends StatefulWidget {
  final Group group; // Recibimos el objeto básico desde la lista

  const GroupDetailPage({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  @override
  void initState() {
    super.initState();
    // Cargar los detalles completos al entrar (miembros, quizzes, ranking)
    context.read<GroupDetailBloc>().add(LoadGroupDetailsEvent(widget.group.id));
  }

  @override
  Widget build(BuildContext context) {
    // Usamos BlocConsumer para escuchar cambios de estado (Listeners) y reconstruir UI (Builder)
    return BlocConsumer<GroupDetailBloc, GroupDetailState>(
      listener: (context, state) {
        // 1. ESCUCHA: Si hay un error, mostrar SnackBar
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }

        // 2. ESCUCHA: Si se generó un link de invitación, mostrar el DIALOG
        if (state.invitationLink != null) {
          showDialog(
            context: context,
            builder: (_) => InviteSuccessDialog(link: state.invitationLink!),
          ).then((_) {
            // Importante: Limpiar el link del estado al cerrar el dialog para no mostrarlo de nuevo
            context.read<GroupDetailBloc>().add(ClearInvitationLinkEvent());
          });
        }

        // 3. ESCUCHA: Si el grupo fue eliminado, volver atrás
        if (state is GroupDeletedState) {
          Navigator.of(context).pop(); // Volver a la lista
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Grupo eliminado correctamente")),
          );
        }
      },
      builder: (context, state) {
        // Mientras carga, mostrar loading, pero mantener la estructura básica
        final bool isLoading = state.isLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Gestionar grupo de estudio",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Menú de opciones (3 puntitos)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  if (value == 'edit') {
                    // Navegar a editar (placeholder)
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditGroupPage(...)));
                  } else if (value == 'delete') {
                    _confirmDeleteGroup(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text("Editar grupo"),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      "Eliminar grupo",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: isLoading && state.members.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- HEADER DEL GRUPO ---
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.group,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget
                              .group
                              .name, // Usamos el nombre del widget padre mientras carga detalles
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${state.members.length} miembros",
                          style: TextStyle(color: Colors.grey[600]),
                        ),

                        const SizedBox(height: 24),

                        // --- BOTONES DE ACCIÓN RÁPIDA ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionButton(
                              icon: Icons.person_add,
                              label: "Invitar",
                              onTap: () {
                                // DISPARADOR: Generar invitación
                                context.read<GroupDetailBloc>().add(
                                  GenerateInvitationEvent(widget.group.id),
                                );
                              },
                            ),
                            _ActionButton(
                              icon: Icons.leaderboard,
                              label: "Ranking",
                              onTap: () {
                                // Navegar a pantalla de ranking detallado (si existe)
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        const Divider(),

                        // --- SECCIÓN: QUIZZES ASIGNADOS ---
                        _SectionHeader(
                          title: "Quizzes Asignados",
                          onTapAdd: () {
                            // Navegar a pantalla de asignar quiz
                          },
                        ),
                        if (state.quizzes.isEmpty)
                          _EmptyStateMessage(
                            msg:
                                "No hay quizzes asignados.\n¡Agrega uno para empezar!",
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = state.quizzes[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.quiz,
                                  color: Colors.purple,
                                ),
                                title: Text(
                                  quiz.quizId,
                                ), // Deberías tener el nombre del quiz aquí
                                subtitle: Text(
                                  "Hasta: ${quiz.availableUntil.toString().split(' ')[0]}",
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              );
                            },
                          ),

                        const Divider(),

                        // --- SECCIÓN: MIEMBROS ---
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Miembros",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.members.length,
                          itemBuilder: (context, index) {
                            final member = state.members[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: Text(
                                  member.userId.substring(0, 1).toUpperCase(),
                                ), // Inicial
                              ),
                              title: Text(
                                member.userId,
                              ), // Deberías mapear ID a Nombre real si lo tienes
                              subtitle: Text(member.role),
                              trailing:
                                  member.role !=
                                      'admin' // Solo permitir borrar si no es admin (simplificado)
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        context.read<GroupDetailBloc>().add(
                                          RemoveMemberEvent(
                                            memberId: member.userId,
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _confirmDeleteGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar grupo"),
        content: const Text("¿Estás seguro? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GroupDetailBloc>().add(
                DeleteGroupEvent(widget.group.id),
              );
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Widgets auxiliares para limpiar el código principal
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTapAdd;

  const _SectionHeader({required this.title, required this.onTapAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.blue),
          onPressed: onTapAdd,
        ),
      ],
    );
  }
}

class _EmptyStateMessage extends StatelessWidget {
  final String msg;
  const _EmptyStateMessage({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
