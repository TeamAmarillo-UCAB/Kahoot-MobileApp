import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../infrastructure/datasource/library_kahoot_datasource_impl.dart';
import '../../infrastructure/repository/library_kahoot_repository_impl.dart';
import '../../presentation/blocs/library_list_cubit.dart';
import 'kahoots_library_page.dart';
import '../../../main.dart';

class KahootsLibraryLoader extends StatefulWidget {
  const KahootsLibraryLoader({Key? key}) : super(key: key);

  @override
  State<KahootsLibraryLoader> createState() => _KahootsLibraryLoaderState();
}

class _KahootsLibraryLoaderState extends State<KahootsLibraryLoader> {
  late final LibraryKahootDatasourceImpl _ds;
  late final LibraryKahootRepositoryImpl _repo;
  late final LibraryListCubit _cubit;

  @override
  void initState() {
    super.initState();
    _ds = LibraryKahootDatasourceImpl();
    _ds.dio.options.baseUrl = apiBaseUrl.trim();
    print('[LIBRARY LOADER] apiBaseUrl usado: ' + _ds.dio.options.baseUrl);
    _repo = LibraryKahootRepositoryImpl(datasource: _ds);
    _cubit = LibraryListCubit(repository: _repo)..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF3A240C),
        body: SafeArea(
          child: BlocBuilder<LibraryListCubit, LibraryListState>(
            builder: (context, state) {
              switch (state.status) {
                case LibraryListStatus.loading:
                case LibraryListStatus.initial:
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFF2C147)));
                case LibraryListStatus.error:
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? 'Error cargando tus kahoots', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _cubit.load(),
                          child: const Text('Reintentar'),
                        )
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
