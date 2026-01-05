import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. IMPORTS DE TUS PÁGINAS
import 'Creacion_edicion_quices/presentation/pages/home/home_page.dart';

// 2. IMPORTS EXACTOS DE TUS ARCHIVOS (Ajusta las rutas si es necesario)
import 'Grupos/infrastructure/datasources/group_datasource_impl.dart'; // La implementación del datasource
import 'Grupos/infrastructure/repositories/group_repository_impl.dart'; // La implementación del repo
import 'Grupos/domain/repositories/group_repository.dart'; // La interfaz abstracta

// 3. IMPORTS DE BLOC Y CASOS DE USO
import 'Grupos/presentation/bloc/group_list/group_list_bloc.dart';
import 'Grupos/application/usecases/get_user_groups.dart';
import 'Grupos/application/usecases/create_group.dart';
import 'Grupos/application/usecases/join_group.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://backcomun-production.up.railway.app',
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AQUI EMPIEZA LA MAGIA DE LA INYECCIÓN
    return MultiRepositoryProvider(
      providers: [
        // 1. Inyectamos el Repositorio
        RepositoryProvider<GroupRepository>(
          create: (context) => GroupRepositoryImpl(
            // Aquí usamos tu clase 'GroupDatasourceImpl'
            datasource: GroupDatasourceImpl(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 2. Inyectamos el Bloc de la lista de grupos
          BlocProvider<GroupListBloc>(
            create: (context) {
              // Buscamos el repositorio que acabamos de crear arriba
              final repository = context.read<GroupRepository>();

              return GroupListBloc(
                getUserGroups: GetUserGroups(repository),
                createGroup: CreateGroup(repository),
                joinGroup: JoinGroup(repository),
                currentUserId:
                    "397b9a84-f851-417e-91da-fdfc271b1a81", // Tu usuario temporal
              );
            },
          ),
        ],
        // AQUI ESTÁ TU MATERIAL APP ORIGINAL
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kahoot',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
            useMaterial3: true,
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}
