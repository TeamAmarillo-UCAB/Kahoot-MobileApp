import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../infrastructure/datasource/library_kahoot_datasource_impl.dart';
import '../../infrastructure/repository/library_kahoot_repository_impl.dart';
import '../../application/get_my_khoots_usecase.dart';
import '../../application/add_kahoot_to_favorite_usecase.dart';
import '../../application/remove_kahoot_from_favorite_usecase.dart';
import '../../application/delete_kahoot_usecase.dart';
import '../../presentation/blocs/library_list_cubit.dart';
import '../../presentation/blocs/favorites_cubit.dart';
import '../../presentation/blocs/delete_kahoot_cubit.dart';
import 'kahoots_library_page.dart';
import '../../../main.dart';
import '../../../config/api_config.dart';

class KahootsLibraryLoader extends StatefulWidget {
  const KahootsLibraryLoader({Key? key}) : super(key: key);

  @override
  State<KahootsLibraryLoader> createState() => _KahootsLibraryLoaderState();
}

class _KahootsLibraryLoaderState extends State<KahootsLibraryLoader> {
  late final LibraryKahootDatasourceImpl _ds;
  late final LibraryKahootRepositoryImpl _repo;
  late final LibraryListCubit _cubit;
  late final FavoritesCubit _favoritesCubit;
  late final DeleteKahootCubit _deleteCubit;

  @override
  void initState() {
    super.initState();
    _ds = LibraryKahootDatasourceImpl();
    _ds.dio.options.baseUrl = ApiConfig().baseUrl.trim();
    print('[LIBRARY LOADER] apiBaseUrl usado: ' + _ds.dio.options.baseUrl);
    _repo = LibraryKahootRepositoryImpl(datasource: _ds);
    _cubit = LibraryListCubit(
      getMyKhoots: GetMyKhootsUseCase(repository: _repo),
    )..load();
    _favoritesCubit = FavoritesCubit(
      addFavorite: AddKahootToFavoriteUseCase(repository: _repo),
      removeFavorite: RemoveKahootFromFavoriteUseCase(repository: _repo),
    );
    _deleteCubit = DeleteKahootCubit(
      deleteKahoot: DeleteKahootUseCase(repository: _repo),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    _favoritesCubit.close();
    _deleteCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _favoritesCubit),
        BlocProvider.value(value: _deleteCubit),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF3A240C),
        body: SafeArea(
          child: BlocBuilder<LibraryListCubit, LibraryListState>(
            builder: (context, state) {
              switch (state.status) {
                case LibraryListStatus.loading:
                case LibraryListStatus.initial:
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF2C147)),
                  );
                case LibraryListStatus.error:
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.errorMessage ?? 'Error cargando tus kahoots',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _cubit.load(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                case LibraryListStatus.loaded:
                  return KahootsLibraryPage(items: state.items);
              }
            },
          ),
        ),
      ),
    );
  }
}
