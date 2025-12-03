import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/kahoot_details_page.dart';
import '../../../infrastructure/datasource/kahoot_datasource_impl.dart';
import '../../../infrastructure/repositories/kahoot_repository_impl.dart';
import '../../../application/usecases/kahoot/get_all_kahoots.dart';
import '../../../application/usecases/kahoot/delete_kahoot.dart';
import '../../../presentation/blocs/kahoot_list_cubit.dart';
import '../../../domain/entities/kahoot.dart';
import '../../../../main.dart';

class CreateKahootPage extends StatefulWidget {
  const CreateKahootPage({Key? key}) : super(key: key);

  @override
  State<CreateKahootPage> createState() => _CreateKahootPageState();
}

class _CreateKahootPageState extends State<CreateKahootPage> {
  late final KahootDatasourceImpl _datasource;
  late final KahootRepositoryImpl _repository;
  late final GetAllKahoots _getAllKahoots;
  late final DeleteKahoot _deleteKahoot;
  late final KahootListCubit _listCubit;

  @override
  void initState() {
    super.initState();
    _datasource = KahootDatasourceImpl();
    _datasource.dio.options.baseUrl = apiBaseUrl;
    _repository = KahootRepositoryImpl(datasource: _datasource);
    _getAllKahoots = GetAllKahoots(_repository);
    _deleteKahoot = DeleteKahoot(_repository);
    _listCubit = KahootListCubit(getAllKahoots: _getAllKahoots);
    _listCubit.load();
  }

  @override
  void dispose() {
    _listCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _listCubit,
      child: Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        title: const Text('Crear', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _TemplateCard(
                icon: Icons.brush,
                title: 'Lienzo en blanco',
                subtitle: 'Toma el control total de la creación de kahoots',
                onTap: () {
                  Navigator.of(context)
                      .push<bool>(
                        MaterialPageRoute(builder: (_) => const KahootDetailsPage()),
                      )
                      .then((saved) {
                        if (saved == true) {
                          _listCubit.load();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kahoot guardado.')),
                          );
                        }
                      });
                },
              ),
            ),
            const SizedBox(height: 16),
            // Listado de kahoots creados
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tus kahoots', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        tooltip: 'Actualizar',
                        onPressed: () => _listCubit.load(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<KahootListCubit, KahootListState>(
                    builder: (context, state) {
                      if (state.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.error != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.error!, style: const TextStyle(color: Colors.black)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _listCubit.load(),
                              icon: const Icon(Icons.refresh, color: Colors.black),
                              label: const Text('Reintentar', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        );
                      }
                      if (state.kahoots.isEmpty) {
                        return const Text('No hay kahoots creados aún.', style: TextStyle(color: Colors.black54));
                      }
                      return Column(
                        children: state.kahoots.map((k) => _KahootItem(
                          kahoot: k,
                          onOpen: () {
                            Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(builder: (_) => KahootDetailsPage(initialKahoot: k)),
                                )
                                .then((saved) {
                                  if (saved == true) {
                                    _listCubit.load();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Kahoot actualizado.')),
                                    );
                                  }
                                });
                          },
                          onDelete: () async {
                            await _deleteKahoot.call(k.kahootId);
                            // Recargar lista luego de eliminar
                            _listCubit.load();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kahoot eliminado.')),
                            );
                          },
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CreateBottomNav(currentIndex: 3),
    ));
  }
}

class _TemplateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _TemplateCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFA46000),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _KahootItem extends StatelessWidget {
  final Kahoot kahoot;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  const _KahootItem({required this.kahoot, required this.onOpen, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFA46000),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onOpen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kahoot.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Visibilidad: ${kahoot.visibility.toShortString()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}



class _CreateBottomNav extends StatelessWidget {
  final int currentIndex;
  const _CreateBottomNav({required this.currentIndex});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFFFFD54F),
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.brown.withOpacity(0.7),
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 3) return; // ya estamos en Crear
        Navigator.of(context).popUntil((r) => r.isFirst); // volver al root
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Descubre'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Unirse'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Crear'),
        BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
      ],
    );
  }
}
