import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import 'nickname_entry_page.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanea el código QR')),
      body: BlocListener<LiveGameBloc, LiveGameBlocState>(
        listener: (context, state) {
          // Si el BLoC procesó el QR con éxito y guardó la sesión
          if (state.session != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NicknameEntryPage()),
            );
          }
          if (state.status == LiveGameStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error al leer QR')),
            );
          }
        },
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                // Enviamos el token al BLoC
                context.read<LiveGameBloc>().add(ScanQrCode(barcode.rawValue!));
              }
            }
          },
        ),
      ),
    );
  }
}
