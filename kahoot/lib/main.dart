import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

// --- Importaciones de tu Arquitectura ---
import 'Contenido_Multimedia/domain/entities/media_resource.dart';
import 'Contenido_Multimedia/domain/repositories/media_resource_repository.dart';
import 'Contenido_Multimedia/domain/datasource/media_resource_datasource.dart';
import 'Contenido_Multimedia/application/usecases/upload_media_resource.dart';
import 'Contenido_Multimedia/application/usecases/get_media_resource.dart';
import 'Contenido_Multimedia/application/usecases/preview_media_resource.dart';
import 'Contenido_Multimedia/application/usecases/delete_media_resource.dart';
import 'Contenido_Multimedia/infrastructure/repositories/media_resource_repository_impl.dart';
import 'Contenido_Multimedia/infrastructure/datasource/media_resource_datasource_impl.dart';

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
  late final MediaResourceDataSource _dataSource;
  late final MediaResourceRepository _repository;
  late final UploadMediaResource _uploadMediaResourceUseCase;
  late final GetMediaResource _getMediaResourceUseCase;
  late final PreviewMediaResource _previewMediaResourceUseCase;
  late final DeleteMediaResource _deleteMediaResourceUseCase;

  String _statusMessage = 'Elige una acción: Subir (⬆️) o Descargar (⬇️).';
  List<int>? _gottenMediaResourceBytes;

  // 🚨 NUEVAS VARIABLES DE ESTADO PARA LA GALERÍA
  List<String>? _availableMediaResourceUrls;
  String? _selectedMediaResourceUrl;

  @override
  void initState() {
    super.initState();
    // 2. Inicialización de la cadena de dependencias
    _dataSource = MediaResourceDatasourceImpl();
    _repository = MediaResourceRepositoryImpl(_dataSource);
    _uploadMediaResourceUseCase = UploadMediaResource(_repository);
    _getMediaResourceUseCase = GetMediaResource(_repository);
    _previewMediaResourceUseCase = PreviewMediaResource(_repository);
    _deleteMediaResourceUseCase = DeleteMediaResource(_repository);
  }

  // ⬇️ FUNCIÓN NUEVA: Descarga los bytes de una URL específica (llamada al seleccionar)
  Future<void> _fetchBytesFromUrl(String url) async {
    setState(() {
      _statusMessage = 'Descargando imagen seleccionada: $url...';
      _selectedMediaResourceUrl = url;
    });

    try {
      // Usamos PreviewImage, que ahora está configurado para manejar la descarga de URLs
      final mediaResourceBytes = await _previewMediaResourceUseCase.call(url);

      setState(() {
        _gottenMediaResourceBytes = mediaResourceBytes;
        _statusMessage = '✅ Imagen seleccionada y cargada exitosamente.';
        _availableMediaResourceUrls =
            null; // Ocultamos la galería después de la selección
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al descargar la imagen: ${e.toString()}';
      });
    }
  }

  // FUNCIÓN AUXILIAR: Encapsula la lógica de la vista previa
  Future<void> _loadPreview(String id) async {
    setState(() {
      _statusMessage = 'Cargando Vista Previa para el ID: $id...';
      _availableMediaResourceUrls = null; // ⬅️ Limpiar galería
      _selectedMediaResourceUrl = null;
    });

    try {
      final mediaResourceBytes = await _previewMediaResourceUseCase.call(id);

      setState(() {
        _gottenMediaResourceBytes = mediaResourceBytes;
        _statusMessage =
            '✅ Operación completa. Vista Previa exitosa. Bytes: ${mediaResourceBytes.length}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al obtener Vista Previa: ${e.toString()}';
      });
    }
  }

  // Función de prueba de Subida (MODIFICADA para limpiar la galería)
  Future<void> _testUpload() async {
    setState(() {
      _statusMessage = 'Seleccionando archivo para subir...';
      _gottenMediaResourceBytes = null;
      _availableMediaResourceUrls = null; // ⬅️ Limpiar galería
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

      final MediaResource fileToUpload = MediaResource(
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
      final responseData = await _uploadMediaResourceUseCase.call(fileToUpload);
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

  // Función de prueba de Descarga (MODIFICADA para cargar la galería)
  Future<void> _testGet() async {
    setState(() {
      _statusMessage = 'Buscando 10 URLs de imágenes...';
      _gottenMediaResourceBytes = null;
      _availableMediaResourceUrls = null; // Limpiar vista anterior
      _selectedMediaResourceUrl = null;
    });

    try {
      const testId = 'ID-para-buscar-en-existencias';

      // 1. Ejecutar Descarga para obtener la LISTA DE URLs (List<String>)
      // 🚨 ASUMIMOS QUE DownloadImage devuelve List<String>
      final urls = await _getMediaResourceUseCase.call(testId) as List<String>;

      setState(() {
        _availableMediaResourceUrls = urls;
        _statusMessage =
            '✅ ${urls.length} URLs obtenidas. Selecciona una imagen.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al obtener URLs: ${e.toString()}';
      });
    }
  }

  // Función de Eliminación (MODIFICADA para limpiar la galería)
  Future<void> _deleteFile() async {
    // Si hay una imagen mostrada O la galería está abierta
    if (_gottenMediaResourceBytes == null &&
        _availableMediaResourceUrls == null) {
      setState(
        () => _statusMessage = 'No hay contenido para eliminar/restablecer.',
      );
      return;
    }

    // Usamos un ID/URL si está disponible, si no, usamos un ID de prueba
    final idToDelete = _selectedMediaResourceUrl ?? 'ID-para-eliminar-mock';

    setState(() {
      _statusMessage = 'Intentando eliminar/restablecer estado...';
    });

    try {
      // 1. Ejecutar la Eliminación (llama al DataSource, limpia mock cache)
      await _deleteMediaResourceUseCase.call(idToDelete);

      // 2. Restablecer el estado de la UI
      setState(() {
        _gottenMediaResourceBytes = null;
        _availableMediaResourceUrls = null; // ⬅️ Limpiar la galería
        _selectedMediaResourceUrl = null;
        _statusMessage = '✅ Archivo/Estado limpiado. Elige otra acción.';
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
              // --- Estado Global ---
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

              // --- Condición 1: Mostrar Galería de Selección ---
              if (_availableMediaResourceUrls != null &&
                  _gottenMediaResourceBytes == null)
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 3 miniaturas por fila
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _availableMediaResourceUrls!.length,
                    itemBuilder: (context, index) {
                      final url = _availableMediaResourceUrls![index];
                      return GestureDetector(
                        onTap: () => _fetchBytesFromUrl(url),
                        child: AspectRatio(
                          // ⬅️ NUEVO WIDGET CLAVE
                          aspectRatio:
                              1.0, // Hace que la miniatura sea cuadrada (1:1)
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
              // --- Condición 2: Mostrar Imagen Única (Vista Previa) ---
              if (_gottenMediaResourceBytes != null) ...[
                const Text(
                  'Vista Previa (Resultado):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Image.memory(
                  Uint8List.fromList(_gottenMediaResourceBytes!),
                  height: 300,
                  width: 300,
                  fit: BoxFit.contain,
                ),
                Text(
                  '(Datos obtenidos de: ${_selectedMediaResourceUrl == null ? 'Subida (Mock Cache)' : 'Descarga API'})',
                  style: const TextStyle(fontSize: 12),
                ),
              ] else
                // --- Condición 3: Placeholder ---
                const Spacer(),
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
            onPressed: _testGet,
            heroTag: 'download',
            tooltip: 'Buscar 10 Imágenes (Galería)',
            child: const Icon(Icons.download),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _deleteFile,
            heroTag: 'delete',
            tooltip: 'Eliminar y Restablecer Vista Previa/Galería',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
