import 'package:flutter/material.dart';
import 'dart:typed_data';

//Imports de dominio, aplicación e infraestructura
import '../../../../Contenido_Multimedia/domain/entities/media_resource.dart';
import '../../../../Contenido_Multimedia/domain/repositories/media_resource_repository.dart';
import '../../../../Contenido_Multimedia/domain/datasource/media_resource_datasource.dart';
import '../../../../Contenido_Multimedia/application/usecases/upload_media_resource.dart';
import '../../../../Contenido_Multimedia/application/usecases/preview_media_resource.dart';
import '../../../../Contenido_Multimedia/application/usecases/get_media_resource.dart';
import '../../../../Contenido_Multimedia/application/usecases/delete_media_resource.dart';
import '../../../../Contenido_Multimedia/infrastructure/repositories/media_resource_repository_impl.dart';
import '../../../../Contenido_Multimedia/infrastructure/datasource/media_resource_datasource_impl.dart';
import '../../../../Contenido_Multimedia/infrastructure/services/file_picker_service.dart';

class MediaResourceSelector extends StatefulWidget {
  const MediaResourceSelector({super.key});

  @override
  State<MediaResourceSelector> createState() => _MediaResourceSelectorState();
}

class _MediaResourceSelectorState extends State<MediaResourceSelector> {
  //Declaración de depedencias
  late final MediaResourceDataSource _dataSource;
  late final MediaResourceRepository _repository;
  late final PreviewMediaResource _previewMediaResourceUseCase;
  late final UploadMediaResource _uploadMediaResourceUseCase;
  late final GetMediaResource _getMediaResourceUseCase;
  late final DeleteMediaResource _deleteMediaResourceUseCase;
  late final FilePickerService _filePickerService;

  //Mensaje de estado
  String _statusMessage = '';
  //Bytes de imagen actual
  List<int>? _gottenMediaResourceBytes;
  //Lista de URL de imágenes obtenidas
  List<String>? _availableMediaResourceUrls;
  //URL de imagen seleccionada
  String? _selectedMediaResourceUrl;

  @override
  void initState() {
    super.initState();
    //Inicialización de dependencias
    _dataSource = MediaResourceDatasourceImpl();
    _repository = MediaResourceRepositoryImpl(_dataSource);
    _uploadMediaResourceUseCase = UploadMediaResource(_repository);
    _previewMediaResourceUseCase = PreviewMediaResource(_repository);
    _getMediaResourceUseCase = GetMediaResource(_repository);
    _deleteMediaResourceUseCase = DeleteMediaResource(_repository);
    _filePickerService = FilePickerServiceImpl();
  }

  //Función para cargar vista previa (al subir un archivo)
  Future<void> _loadPreview(String id) async {
    setState(() {
      _statusMessage = 'Cargando Vista Previa...';
      _availableMediaResourceUrls = null;
      _selectedMediaResourceUrl = null;
    });

    try {
      //Llama al caso de uso del preview (descarga los bytes de la URL)
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

  //Función para subir archivo
  Future<void> _testUpload() async {
    setState(() {
      _statusMessage = 'Seleccionando archivo para subir...';
      _gottenMediaResourceBytes = null;
      _availableMediaResourceUrls = null;
    });

    try {
      // Obtiene el archivo del servicio Filepicker
      final MediaResource? fileToUpload = await _filePickerService
          .pickImageResource();

      if (fileToUpload == null) {
        setState(() => _statusMessage = 'Subida cancelada por el usuario.');
        return;
      }

      setState(() {
        _statusMessage = 'Subiendo...';
      });

      // Llama al caso de uso de subida
      final responseData = await _uploadMediaResourceUseCase.call(fileToUpload);

      final uploadedId = responseData['id'] as String;

      //Carga la vista previa del archivo
      await _loadPreview(uploadedId);
      setState(() {
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error de Subida: ${e.toString()}';
      });
      print('ERROR: $e');
    }
  }

  //Método llamado cuando se da a una de las imágenes de la URL
  Future<void> _fetchBytesFromUrl(String id) async {
    setState(() {
      _statusMessage = 'Cargando archivo...';
      _selectedMediaResourceUrl = id;
      _availableMediaResourceUrls = null;
    });

    try {
      //Llama al caso de uso del preview
      final mediaResourceBytes = await _previewMediaResourceUseCase.call(id);

      setState(() {
        _gottenMediaResourceBytes = mediaResourceBytes; //Almacena los bytes
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

      // Llamada al caso de uso getMedia
      final ids = await _getMediaResourceUseCase.call(testId);

      setState(() {
        _availableMediaResourceUrls = ids; // Almacena los IDs
        _statusMessage = 'Selecciona la que más te guste';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al obtener IDs: ${e.toString()}';
      });
    }
  }

  //Variable de estado de borrado
  bool _isDeleting = false;
  // Función para borrar el archivo
  Future<void> _deleteFile() async {
    if (_isDeleting) return; // Previene múltiples toques mientras carga

    if (_gottenMediaResourceBytes == null &&
        _availableMediaResourceUrls == null) {
      setState(
        () => _statusMessage = 'No has seleccionado todavía un archivo.',
      );
      return;
    }

    // Definir el ID a eliminar
    final idToDelete = _selectedMediaResourceUrl ?? 'ID-para-eliminar-mock';

    setState(() {
      _statusMessage = 'Eliminando archivo...';
      _isDeleting = true; // Activa indicador de carga
    });

    try {
      // Llamada al caso de uso de eliminar
      await _deleteMediaResourceUseCase.call(idToDelete);

      setState(() {
        // Limpia la imagen previa
        _gottenMediaResourceBytes = null;
        _availableMediaResourceUrls = null;
        _selectedMediaResourceUrl = null;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al eliminar el archivo: ${e.toString()}';
      });
    } finally {
      // Desactiva indicador de carga
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define si el estado actual es de carga (para mostrar un indicador o el mensaje)
    final bool isInitialOrFinishedState =
        _statusMessage == 'Elige un archivo.' ||
        _statusMessage.isEmpty ||
        _statusMessage.contains('Error');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _gottenMediaResourceBytes != null
          ? Center(
              // La imagen está cargada
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.memory(
                        Uint8List.fromList(_gottenMediaResourceBytes!),
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      //Botón de eliminar archivo
                      Positioned(
                        top: -24,
                        right: -24,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(4),
                          ),
                          onPressed: _deleteFile,
                          tooltip: 'Eliminar imagen',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : (_availableMediaResourceUrls != null &&
                _availableMediaResourceUrls!.isNotEmpty)
          ? Column(
              // La galería es visible
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableMediaResourceUrls!.length,
                  itemBuilder: (context, index) {
                    final mediaId = _availableMediaResourceUrls![index];
                    return GestureDetector(
                      onTap: () => _fetchBytesFromUrl(mediaId),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: FutureBuilder<List<int>>(
                          future: _previewMediaResourceUseCase.call(mediaId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return Image.memory(
                                  Uint8List.fromList(snapshot.data!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    );
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return const Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                );
                              }
                            }
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _availableMediaResourceUrls = null),
                    child: const Text(
                      'Cerrar Galería',
                      style: TextStyle(color: Color(0xFFFFD54F)),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              // Carga del archivo
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Muestra los botones si no está cargando
                if (isInitialOrFinishedState) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Añadir multimedia desde:',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.folder_open,
                          color: Color(0xFFFFD54F),
                        ),
                        iconSize: 32,
                        onPressed: _testUpload,
                        tooltip: 'Subir archivo local',
                      ),
                      const SizedBox(width: 32),
                      IconButton(
                        icon: const Icon(
                          Icons.collections,
                          color: Color(0xFFFFD54F),
                        ),
                        iconSize: 32,
                        onPressed: _testGet,
                        tooltip: 'Seleccionar de galería',
                      ),
                    ],
                  ),
                ] else if (_statusMessage.contains('Cargando'))
                  //Indicador de progreso
                  const CircularProgressIndicator(color: Color(0xFFFFD54F)),
              ],
            ),
    );
  }
}
