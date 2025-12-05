import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

//Imports (asumimos que estos son correctos)
import 'Contenido_Multimedia/domain/entities/media_resource.dart';
import 'Contenido_Multimedia/domain/repositories/media_resource_repository.dart';
import 'Contenido_Multimedia/domain/datasource/media_resource_datasource.dart';
import 'Contenido_Multimedia/application/usecases/upload_media_resource.dart';
import 'Contenido_Multimedia/application/usecases/get_media_resource.dart';
import 'Contenido_Multimedia/application/usecases/preview_media_resource.dart';
import 'Contenido_Multimedia/application/usecases/delete_media_resource.dart';
import 'Contenido_Multimedia/infrastructure/repositories/media_resource_repository_impl.dart';
import 'Contenido_Multimedia/infrastructure/datasource/media_resource_datasource_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

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

class _MyHomePageState extends State<MyHomePage> {
  //Declaración del datasource, repositorio y casos de uso
  late final MediaResourceDataSource _dataSource;
  late final MediaResourceRepository _repository;
  late final UploadMediaResource _uploadMediaResourceUseCase;
  late final GetMediaResource _getMediaResourceUseCase;
  late final PreviewMediaResource _previewMediaResourceUseCase;
  late final DeleteMediaResource _deleteMediaResourceUseCase;

  String _statusMessage = 'Elige un archivo.';

  //Bytes del recurso extraído
  List<int>? _gottenMediaResourceBytes;
  //URLs de los archivos (ahora contiene IDs de la API)
  List<String>? _availableMediaResourceUrls;
  //URL del archivo seleccionado (ahora contiene el ID seleccionado)
  String? _selectedMediaResourceUrl;

  @override
  void initState() {
    super.initState();
    //instanciación del datasource, el repositorio y los casos de uso
    _dataSource = MediaResourceDatasourceImpl();
    _repository = MediaResourceRepositoryImpl(_dataSource);
    _uploadMediaResourceUseCase = UploadMediaResource(_repository);
    _getMediaResourceUseCase = GetMediaResource(_repository);
    _previewMediaResourceUseCase = PreviewMediaResource(_repository);
    _deleteMediaResourceUseCase = DeleteMediaResource(_repository);
  }

  //Método llamado cuando se da a una de las imágenes de la URL (Recibe el ID)
  Future<void> _fetchBytesFromUrl(String id) async {
    // 1. Primer setState: Oculta la galería e indica que está cargando.
    setState(() {
      _statusMessage = 'Cargando archivo...';
      _selectedMediaResourceUrl = id;
      _availableMediaResourceUrls = null; // Oculta la galería de inmediato.
    });

    try {
      // Llama al caso de uso del preview (descarga los bytes del ID)
      final mediaResourceBytes = await _previewMediaResourceUseCase.call(id);

      // 2. ÉXITO: Guardamos los bytes y LIMPIAMOS EL MENSAJE DE ESTADO.
      setState(() {
        _gottenMediaResourceBytes = mediaResourceBytes; // Almacena los bytes

        // 🛑 CORRECCIÓN: Limpiamos el mensaje de estado aquí.
        _statusMessage = '';
      });
    } catch (e) {
      // Si la descarga falla
      setState(() {
        _statusMessage = 'Error al descargar el archivo: ${e.toString()}';
        _gottenMediaResourceBytes = null;
      });
    }
  }

  //Función que carga el preview de las imágenes subidas
  Future<void> _loadPreview(String id) async {
    setState(() {
      _statusMessage = 'Cargando Vista Previa para el ID: $id...';
      _availableMediaResourceUrls = null;
      _selectedMediaResourceUrl = null;
    });

    try {
      //Llama al caso de uso del preview (descarga los bytes del ID)
      final mediaResourceBytes = await _previewMediaResourceUseCase.call(id);

      setState(() {
        _gottenMediaResourceBytes =
            mediaResourceBytes; //Almacena los bytes del archivo
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al obtener Vista Previa: ${e.toString()}';
      });
    }
  }

  //Función para subir el archivo
  Future<void> _testUpload() async {
    setState(() {
      _statusMessage = 'Seleccionando archivo para subir...';
      _gottenMediaResourceBytes = null;
      _availableMediaResourceUrls = null;
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
      //Conversión a MediaResource
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

      final responseData = await _uploadMediaResourceUseCase.call(
        fileToUpload,
      ); //Llamada al caso de uso upload
      final uploadedId = responseData['id'] as String;

      await _loadPreview(uploadedId); //Llama al preview para que la muestre
    } catch (e) {
      setState(() {
        _statusMessage = 'Error de Subida: ${e.toString()}';
      });
      print('ERROR: $e');
    }
  }

  //Función para obtener las imágenes de prueba
  Future<void> _testGet() async {
    setState(() {
      _statusMessage = 'Cargando imágenes...';
      _gottenMediaResourceBytes = null;
      _availableMediaResourceUrls = null;
      _selectedMediaResourceUrl = null;
    });

    try {
      const testId = 'ID-para-buscar-en-existencias';

      final ids = await _getMediaResourceUseCase.call(
        testId,
      ); //Llamada al caso de uso de obtener los IDs

      setState(() {
        _availableMediaResourceUrls = ids; // Almacena los IDs de las imágenes
        _statusMessage = 'Selecciona la que más te guste';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al obtener IDs: ${e.toString()}';
      });
    }
  }

  //Función para borrar el archivo
  Future<void> _deleteFile() async {
    if (_gottenMediaResourceBytes == null &&
        _availableMediaResourceUrls == null) {
      setState(
        () => _statusMessage = 'No has seleccionado todavía un archivo.',
      );
      return;
    }

    final idToDelete = _selectedMediaResourceUrl ?? 'ID-para-eliminar-mock';

    setState(() {
      _statusMessage = 'Eliminando archivo...';
    });

    try {
      await _deleteMediaResourceUseCase.call(
        idToDelete,
      ); //Llamada al caso de uso de borrar

      setState(() {
        //Limpia todo lo que había actualmente
        _gottenMediaResourceBytes = null;
        _availableMediaResourceUrls = null;
        _selectedMediaResourceUrl = null;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al eliminar el archivo: ${e.toString()}';
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
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // CORRECCIÓN: Usar FutureBuilder y Image.memory para manejar IDs
              if (_availableMediaResourceUrls != null &&
                  _gottenMediaResourceBytes == null)
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, //4 archivos por fila
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _availableMediaResourceUrls!.length,
                    itemBuilder: (context, index) {
                      final mediaId =
                          _availableMediaResourceUrls![index]; // Este es el ID

                      return GestureDetector(
                        // Llama a la función de selección con el ID
                        onTap: () => _fetchBytesFromUrl(mediaId),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          // Usamos FutureBuilder para obtener los bytes del ID
                          child: FutureBuilder<List<int>>(
                            future: _previewMediaResourceUseCase.call(mediaId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  // Si tenemos los bytes, mostramos la imagen en memoria
                                  return Image.memory(
                                    Uint8List.fromList(snapshot.data!),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      );
                                    },
                                  );
                                } else if (snapshot.hasError) {
                                  // Muestra un icono de error si falla la descarga o el parseo
                                  return const Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                  );
                                }
                              }
                              // Muestra un indicador de carga mientras espera
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
              //Si ya obtuvo un archivo, la muestra en pantalla
              else if (_gottenMediaResourceBytes != null) ...[
                const SizedBox(height: 10),
                Image.memory(
                  Uint8List.fromList(_gottenMediaResourceBytes!),
                  height: 300,
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ] else
                const Spacer(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //Botón para subir el archivo
          FloatingActionButton(
            onPressed: _testUpload, //Llamada a la función de subir archivo
            heroTag: 'upload',
            tooltip: 'Subir Archivo (Subida -> Vista Previa)',
            child: const Icon(Icons.upload),
          ),
          const SizedBox(height: 10),
          //Botón de extraer archivo
          FloatingActionButton(
            onPressed: _testGet, //Llamada a la función de extraer archivo
            heroTag: 'download',
            tooltip: 'Buscar imágenes de la API',
            child: const Icon(Icons.download),
          ),
          const SizedBox(height: 10),
          //Botón de eliminar archivo
          FloatingActionButton(
            onPressed: _deleteFile, //Llamada a la función de borrar archivo
            heroTag: 'delete',
            tooltip: 'Eliminar y Restablecer Vista Previa/Galería',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
