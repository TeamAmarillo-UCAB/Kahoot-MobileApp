import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import '../live_game_page.dart';

class NicknameEntryPage extends StatefulWidget {
  final String pin;
  const NicknameEntryPage({super.key, required this.pin});

  @override
  State<NicknameEntryPage> createState() => _NicknameEntryPageState();
}

class _NicknameEntryPageState extends State<NicknameEntryPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveGameBloc, LiveGameBlocState>(
      listener: (context, state) {
        if (state.status == LiveGameStatus.lobby) {
          print("Nickname aceptado. Entrando a la sesión de juego...");

          final liveGameBloc = context.read<LiveGameBloc>();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: liveGameBloc,
                child: const LiveGamePage(),
              ),
            ),
          );
        }

        if (state.status == LiveGameStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error al unirse')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF46178F),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.person_pin, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  "PIN DE JUEGO: ${widget.pin}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  "¿Cómo te llamas?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Tu apodo aquí",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<LiveGameBloc, LiveGameBlocState>(
                  builder: (context, state) {
                    final isLoading = state.status == LiveGameStatus.loading;
                    return SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_controller.text.trim().isNotEmpty) {
                                  context.read<LiveGameBloc>().add(
                                    JoinLobby(_controller.text.trim()),
                                  );
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "¡LISTO!",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
