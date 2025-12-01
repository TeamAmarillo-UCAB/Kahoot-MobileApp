import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

//Imports
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
  //URLs de los archivos
  List<String>? _availableMediaResourceUrls;
  //URL del archivo seleccionado
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

  //Método llamado cuando se da a una de las imágenes de la URL
  Future<void> _fetchBytesFromUrl(String url) async {
    setState(() {
      _statusMessage = 'Descargando archivo seleccionado: $url...';
      _selectedMediaResourceUrl = url;
    });

    try {
      //Llama al caso de uso del preview (descarga los bytes de la URL)
      final mediaResourceBytes = await _previewMediaResourceUseCase.call(url);

      setState(() {
        _gottenMediaResourceBytes =
            mediaResourceBytes; //Almacena los bytes del archivo
        _statusMessage = 'Archivo seleccionado y cargada exitosamente.';
        _availableMediaResourceUrls = null; //Limpia los otros URLs
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al descargar el archivo: ${e.toString()}';
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
      //Llama al caso de uso del preview (descarga los bytes de la URL)
      final mediaResourceBytes = await _previewMediaResourceUseCase.call(id);

      setState(() {
        _gottenMediaResourceBytes =
            mediaResourceBytes; //Almacena los bytes del archivo
        _statusMessage =
            'Operación completa. Vista Previa exitosa. Bytes: ${mediaResourceBytes.length}';
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
      _statusMessage = 'Buscando 16 URLs de imágenes...';
      _gottenMediaResourceBytes = null;
      _availableMediaResourceUrls = null;
      _selectedMediaResourceUrl = null;
    });

    try {
      const testId = 'ID-para-buscar-en-existencias';

      final urls = await _getMediaResourceUseCase.call(
        testId,
      ); //Llamada al caso de uso de obtener las imágenes

      setState(() {
        _availableMediaResourceUrls = urls;
        _statusMessage =
            ' ${urls.length} URLs obtenidas. Selecciona la que más te guste';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al obtener URLs: ${e.toString()}';
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
        _statusMessage = 'Archivo eliminado. Elige otra acción.';
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
              //Si hay imágenes para ver pero ninguna para elegir
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
                      final url = _availableMediaResourceUrls![index];
                      return GestureDetector(
                        //Al tocar una de las imágenes de la galería, llama a la función
                        onTap: () => _fetchBytesFromUrl(url),
                        child: AspectRatio(
                          aspectRatio: 1.0,
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
              //Si ya obtuvo un archivo, la muestra en pantalla
              else if (_gottenMediaResourceBytes != null) ...[
                const Text(
                  'Archivo seleccionado:',
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
                  '(Archivo: ${_selectedMediaResourceUrl == null ? 'Subida' : 'De la API'})',
                  style: const TextStyle(fontSize: 12),
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
            tooltip: 'Buscar 16 imágenes de la API',
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
