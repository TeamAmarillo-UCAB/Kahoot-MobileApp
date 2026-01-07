import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';

class NicknameEntryPage extends StatefulWidget {
  const NicknameEntryPage({super.key});

  @override
  State<NicknameEntryPage> createState() => _NicknameEntryPageState();
}

class _NicknameEntryPageState extends State<NicknameEntryPage> {
  final TextEditingController _nickController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu Nickname')),
      body: BlocConsumer<LiveGameBloc, LiveGameBlocState>(
        listener: (context, state) {
          if (state.status == LiveGameStatus.lobby) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PIN: ${state.pin ?? '---'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nickController,
                  decoration: const InputDecoration(
                    labelText: '¿Cómo quieres que te llamen?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                if (state.status == LiveGameStatus.loading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      if (_nickController.text.isNotEmpty) {
                        context.read<LiveGameBloc>().add(
                          JoinLobby(_nickController.text),
                        );
                      }
                    },
                    child: const Text('¡Unirse al Lobby!'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
