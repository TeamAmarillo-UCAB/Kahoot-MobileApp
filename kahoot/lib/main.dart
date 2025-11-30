import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

// --- Importaciones de tu Arquitectura ---
import 'Contenido_Multimedia/domain/entities/media_file.dart';
import 'Contenido_Multimedia/domain/repositories/image_repository.dart';
import 'Contenido_Multimedia/domain/datasource/image_datasource.dart';
import 'Contenido_Multimedia/application/usecases/upload_image.dart';
import 'Contenido_Multimedia/application/usecases/get_image.dart';
import 'Contenido_Multimedia/application/usecases/preview_image.dart';
import 'Contenido_Multimedia/application/usecases/delete_image.dart';
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

class _MyHomePageState extends State<MyHomePage> {
  // 1. Declaración de las dependencias
  late final ImageDataSource _dataSource;
  late final ImageRepository _repository;
  late final UploadImage _uploadImageUseCase;
  late final DownloadImage _downloadImageUseCase;
  late final PreviewImage _previewImageUseCase;
  late final DeleteImage _deleteImageUseCase;

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
    _previewImageUseCase = PreviewImage(_repository);
    _deleteImageUseCase = DeleteImage(_repository);
  }

  // FUNCIÓN AUXILIAR: Encapsula la lógica de la vista previa
  Future<void> _loadPreview(String id) async {
    setState(() {
      _statusMessage = 'Cargando Vista Previa para el ID: $id...';
    });

    try {
      final imageBytes = await _previewImageUseCase.call(id);

      setState(() {
        _downloadedImageBytes = imageBytes;
        _statusMessage =
            '✅ Operación completa. Vista Previa exitosa. Bytes: ${imageBytes.length}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al obtener Vista Previa: ${e.toString()}';
      });
    }
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

      // 1. Ejecutar Subida
      final responseData = await _uploadImageUseCase.call(fileToUpload);
      final uploadedId = responseData['id'] as String;

      // 2. Saltar a la Vista Previa después de la subida.
      await _loadPreview(uploadedId);
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error de Subida: ${e.toString()}';
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

      // 1. Ejecutar Descarga (simular la acción)
      await _downloadImageUseCase.call(testId);

      // 2. Saltar a la Vista Previa después de la descarga.
      await _loadPreview(testId);
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error de Descarga/Búsqueda: ${e.toString()}';
      });
    }
  }

  Future<void> _deleteFile() async {
    if (_downloadedImageBytes == null) {
      setState(
        () => _statusMessage = 'No hay archivo en vista previa para eliminar.',
      );
      return;
    }

    // Usamos un ID de prueba (el que se usó para la subida o descarga)
    // Nota: Esto asume que el ID es persistente, pero para la prueba mock lo tratamos como "eliminado".
    const testId = 'ID-para-buscar-en-existencias';

    setState(() {
      _statusMessage = 'Intentando eliminar archivo con ID: $testId...';
    });

    try {
      // 1. Ejecutar la Eliminación (llama al DataSource)
      await _deleteImageUseCase.call(testId);

      // 2. Restablecer el estado de la UI
      setState(() {
        _downloadedImageBytes = null;
        _statusMessage =
            '✅ Archivo eliminado y vista previa restablecida. Elige otra acción.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al eliminar el archivo: ${e.toString()}';
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
                  'Vista Previa (Resultado):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Image.memory(
                  Uint8List.fromList(_downloadedImageBytes!),
                  height: 200,
                  width: 300,
                  fit: BoxFit.contain,
                ),
                const Text(
                  '(Datos obtenidos por el caso de uso PreviewImage)',
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
            tooltip: 'Subir Imagen (Subida -> Vista Previa)',
            child: const Icon(Icons.upload),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _testDownload,
            heroTag: 'download',
            tooltip: 'Descargar Mock (Descarga -> Vista Previa)',
            child: const Icon(Icons.download),
          ),
          const SizedBox(height: 10), // ⬅️ NUEVO ESPACIO
          FloatingActionButton(
            // ⬅️ BOTÓN DE ELIMINACIÓN
            onPressed: _deleteFile,
            heroTag: 'delete',
            tooltip: 'Eliminar y Restablecer Vista Previa',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
