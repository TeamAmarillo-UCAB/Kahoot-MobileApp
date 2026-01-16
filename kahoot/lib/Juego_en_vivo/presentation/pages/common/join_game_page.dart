import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../infrastructure/repositories/live_game_repository_impl.dart';
import '../../../infrastructure/datasource/live_game_datasource_impl.dart';

import '../../bloc/live_game_bloc.dart';
import '../../bloc/live_game_event.dart';
import '../../bloc/live_game_state.dart';
import '../common/nickname_entry_page.dart';

import '../../../../config/api_config.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({Key? key}) : super(key: key);

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  late final LiveGameBloc _bloc;
  final TextEditingController _pinController = TextEditingController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();

    //Dio
    final dio = Dio(BaseOptions(baseUrl: ApiConfig().baseUrl));

    //Infraestructura
    final datasource = LiveGameDatasourceImpl(dio: dio);
    final repository = LiveGameRepositoryImpl(datasource: datasource);

    // Inicializar bloc
    _bloc = LiveGameBloc(repository: repository);
  }

  @override
  void dispose() {
    _bloc.close();
    _pinController.dispose();
    super.dispose();
  }

  void _showScanner(BuildContext context) {
    _isScanning = false;
    final MobileScannerController scannerController = MobileScannerController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          controller: scannerController,
          onDetect: (capture) {
            if (_isScanning) return;

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _isScanning = true;
                final String code = barcode.rawValue!;

                _bloc.add(ScanQrCode(code));

                scannerController.stop();
                Navigator.pop(context);
                break;
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Proveer el bloc
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.amber,
        body: BlocListener<LiveGameBloc, LiveGameBlocState>(
          listener: (context, state) {
            if (state.pin != null && _pinController.text != state.pin) {
              _pinController.text = state.pin!;
            }

            if (state.pin != null &&
                (state.status == LiveGameStatus.initial ||
                    state.status == LiveGameStatus.lobby)) {
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
                  'Introduce el PIN',
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
                  keyboardType: TextInputType.number,
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
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _showScanner(context),
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'ESCANEAR QR',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
