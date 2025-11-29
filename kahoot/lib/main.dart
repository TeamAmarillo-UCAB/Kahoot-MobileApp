// Archivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data'; // Necesario para Uint8List y Image.memory

// --- Importaciones de tu Arquitectura ---
import 'Contenido_Multimedia/domain/entities/media_file.dart';
import 'Contenido_Multimedia/domain/repositories/image_repository.dart';
import 'Contenido_Multimedia/domain/datasource/image_datasource.dart';
import 'Contenido_Multimedia/application/usecases/upload_image.dart';
import 'Contenido_Multimedia/application/usecases/get_image.dart';
import 'Contenido_Multimedia/infrastructure/repositories/image_repository_impl.dart';
import 'Contenido_Multimedia/infrastructure/datasource/image_datasource_impl.dart';

// -------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// -------------------------------------------------------------
// CLASES DE WIDGETS
// -------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // MyHomePage DEBE ESTAR DEFINIDO antes de ser usado aquí.
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// -------------------------------------------------------------
// CLASE DE ESTADO
// -------------------------------------------------------------

// ⬅️ La sintaxis es correcta: State<MyHomePage>
class _MyHomePageState extends State<MyHomePage> {
  // 1. Declaración de las dependencias
  late final ImageDataSource _dataSource;
  late final ImageRepository _repository;
  late final UploadImage _uploadImageUseCase;
  late final DownloadImage _downloadImageUseCase;

  String _statusMessage = 'Elige una acción: Subir (⬆️) o Descargar Mock (⬇️).';
  List<int>? _downloadedImageBytes;

  @override
  void initState() {
    super.initState();
    // 2. Inicialización de la cadena de dependencias
    _dataSource = ImageDatasourceImpl();
    _repository = ImageRepositoryImpl(_dataSource);
    _uploadImageUseCase = UploadImage(_repository);
    _downloadImageUseCase = DownloadImage(_repository);
  }

  // Función de prueba de Subida
  Future<void> _testUpload() async {
    setState(() {
      _statusMessage = 'Seleccionando archivo para subir...';
      _downloadedImageBytes = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'webp'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _statusMessage = 'Subida cancelada por el usuario.');
        return;
      }

      PlatformFile platformFile = result.files.first;
      Uint8List? fileBytes = platformFile.bytes;
      if (fileBytes == null || fileBytes.isEmpty) {
        setState(
          () => _statusMessage = 'Error: No se pudieron leer los bytes.',
        );
        return;
      }

      final MediaFile fileToUpload = MediaFile(
        bytes: fileBytes.toList(),
        name: platformFile.name,
        mimeType: platformFile.extension != null
            ? 'image/${platformFile.extension}'
            : null,
      );

      setState(() {
        _statusMessage = 'Subiendo ${fileToUpload.name}...';
      });
      final responseData = await _uploadImageUseCase.call(fileToUpload);

      setState(() {
        _statusMessage = '✅ ¡Subida exitosa! UUID: ${responseData['id']}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error de subida: ${e.toString()}';
      });
      print('ERROR: $e');
    }
  }

  // Función de prueba de Descarga
  Future<void> _testDownload() async {
    setState(() {
      _statusMessage = 'Iniciando búsqueda Mock (Descarga)...';
      _downloadedImageBytes = null;
    });

    try {
      const testId = 'ID-para-buscar-en-existencias';
      final imageBytes = await _downloadImageUseCase.call(testId);

      setState(() {
        _downloadedImageBytes = imageBytes;
        _statusMessage =
            '✅ Búsqueda/Descarga Mock exitosa. Bytes recibidos: ${imageBytes.length}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error de Descarga/Búsqueda: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Estado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (_downloadedImageBytes != null) ...[
                const Text(
                  'Imagen Mock (GIF 1x1):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Image.memory(
                  Uint8List.fromList(_downloadedImageBytes!),
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
                const Text(
                  '(Se simula la persistencia)',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _testUpload,
            heroTag: 'upload',
            tooltip: 'Subir Imagen de Prueba',
            child: const Icon(Icons.upload),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _testDownload,
            heroTag: 'download',
            tooltip: 'Buscar/Descargar Mock',
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }
}
