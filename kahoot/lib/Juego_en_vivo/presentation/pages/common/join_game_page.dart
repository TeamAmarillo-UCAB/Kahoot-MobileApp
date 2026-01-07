import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

// Importaciones de infraestructura (según tus indicaciones)
import '../../../infrastructure/repositories/live_game_repository_impl.dart';
import '../../../infrastructure/datasource/live_game_datasource_impl.dart';

// BLoC y pantallas
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import '../common/nickname_entry_page.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({Key? key}) : super(key: key);

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  late final LiveGameBloc _bloc;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 1. Configuramos Dio
    final dio = Dio(
      BaseOptions(baseUrl: 'https://quizzy-backend-0wh2.onrender.com'),
    );

    // 2. Instanciamos la infraestructura
    final datasource = LiveGameDatasourceImpl(dio: dio);
    final repository = LiveGameRepositoryImpl(datasource: datasource);

    // 3. Inicializamos el BLoC (Aquí se resuelve el LateError)
    // El BLoC se encarga de sus propios casos de uso
    _bloc = LiveGameBloc(repository: repository);
  }

  @override
  void dispose() {
    _bloc.close();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Proveemos el BLoC a la vista
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF46178F),
        body: BlocListener<LiveGameBloc, LiveGameBlocState>(
          listener: (context, state) {
            // Si el PIN es válido, navegamos pasando el BLoC existente
            if (state.pin != null && state.status == LiveGameStatus.initial) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: _bloc,
                    child: NicknameEntryPage(pin: state.pin!),
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'QUIZZY',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _pinController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'PIN DE JUEGO',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_pinController.text.isNotEmpty) {
                      _bloc.add(InitPlayerSession(_pinController.text));
                    }
                  },
                  child: const Text('INGRESAR'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
