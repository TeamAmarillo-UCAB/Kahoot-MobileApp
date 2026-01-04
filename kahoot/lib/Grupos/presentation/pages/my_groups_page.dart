import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_list/group_list_bloc.dart';
import '../bloc/group_list/group_list_state.dart';
import '../bloc/group_list/group_list_event.dart';
import 'create_group_page.dart';
import 'group_detail_page.dart';
import '../widgets/custom_bottom_nav.dart';

class MyGroupsPage extends StatefulWidget {
  @override
  _MyGroupsPageState createState() => _MyGroupsPageState();
}

class _MyGroupsPageState extends State<MyGroupsPage> {
  @override
  void initState() {
    super.initState();
    // Carga inicial de grupos
    context.read<GroupListBloc>().add(LoadGroupsEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Guardamos la referencia del Bloc actual para usarla en los navigators
    final groupListBloc = context.read<GroupListBloc>();

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Volver", style: TextStyle(color: Colors.black)),
        ),
        leadingWidth: 80,
        title: const Text(
          "Mis grupos de estudio",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 30),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                // <--- CORRECCIÓN 1: Envolvemos CreateGroupPage con BlocProvider.value
                builder: (_) => BlocProvider.value(
                  value: groupListBloc,
                  child: CreateGroupPage(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<GroupListBloc, GroupListState>(
        builder: (context, state) {
          if (state is GroupListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupListError) {
            return Center(child: Text(state.message));
          }

          if (state is GroupListLoaded) {
            if (state.groups.isEmpty) {
              return const Center(
                child: Text(
                  "No estás en ningún grupo...\nPide el link a un amigo o crea tu propio grupo",
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final group = state.groups[index];

                return GestureDetector(
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // <--- CORRECCIÓN 2: Envolvemos GroupDetailPage con BlocProvider.value
                          builder: (_) => BlocProvider.value(
                            value: groupListBloc,
                            child: GroupDetailPage(group: group),
                          ),
                        ),
                      ).then((_) {
                        // Recargar la lista al volver por si se borró el grupo o cambió el nombre
                        groupListBloc.add(LoadGroupsEvent());
                      }),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                          ),
                          child: const Icon(
                            Icons.group,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${group.memberCount} miembros",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 4, onTap: (i) {}),
    );
  }
}
