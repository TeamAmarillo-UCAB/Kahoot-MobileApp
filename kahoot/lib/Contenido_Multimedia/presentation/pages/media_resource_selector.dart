import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import '../../../../Contenido_Multimedia/domain/entities/media_resource.dart';
import '../../../../Contenido_Multimedia/domain/repositories/media_resource_repository.dart';
import '../../../../Contenido_Multimedia/domain/datasource/media_resource_datasource.dart';
import '../../../../Contenido_Multimedia/application/usecases/upload_media_resource.dart';
import '../../../../Contenido_Multimedia/application/usecases/preview_media_resource.dart';
import '../../../../Contenido_Multimedia/application/usecases/get_media_resource.dart';
import '../../../../Contenido_Multimedia/application/usecases/delete_media_resource.dart';
import '../../../../Contenido_Multimedia/infrastructure/repositories/media_resource_repository_impl.dart';
import '../../../../Contenido_Multimedia/infrastructure/datasource/media_resource_datasource_impl.dart';

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

  //Mensaje de estado
  String _statusMessage = 'Elige un archivo.';
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
  }

  //Función para cargar vista previa
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

  //
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
        _statusMessage = 'Subiendo...';
      });

      final responseData = await _uploadMediaResourceUseCase.call(
        fileToUpload,
      ); //Llamada al caso de uso upload
      final uploadedId = responseData['id'] as String;

      await _loadPreview(uploadedId); //Llama al preview para que la muestre
      _statusMessage = '';
    } catch (e) {
      setState(() {
        _statusMessage = 'Error de Subida: ${e.toString()}';
      });
      print('ERROR: $e');
    }
  }

  //Método llamado cuando se da a una de las imágenes de la URL
  Future<void> _fetchBytesFromUrl(String url) async {
    setState(() {
      //_statusMessage = 'Descargando archivo seleccionado: $url...';
      _selectedMediaResourceUrl = url;
    });

    try {
      //Llama al caso de uso del preview (descarga los bytes de la URL)
      final mediaResourceBytes = await _previewMediaResourceUseCase.call(url);

      setState(() {
        _gottenMediaResourceBytes =
            mediaResourceBytes; //Almacena los bytes del archivo
        //_statusMessage = 'Archivo seleccionado y cargada exitosamente.';
        _statusMessage = '';
        _availableMediaResourceUrls = null; //Limpia los otros URLs
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al descargar el archivo: ${e.toString()}';
      });
    }
  }

  //Función para obtener las imágenes de prueba
  Future<void> _testGet() async {
    setState(() {
      _statusMessage = 'Buscando 16 imágenes...';
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
        _statusMessage = 'Selecciona la que más te guste';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _gottenMediaResourceBytes != null
          ? Center(
              // 🟢 OPCIÓN 1: IMAGEN CARGADA (Vista Previa con botón de eliminar)
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
                          onPressed: _deleteFile, // ⬅️ Llama a _deleteFile
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
              // 🟡 OPCIÓN 2: GALERÍA VISIBLE
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
                    final url = _availableMediaResourceUrls![index];
                    return GestureDetector(
                      onTap: () => _fetchBytesFromUrl(url),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
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
              // 🔴 OPCIÓN 3: PLACEHOLDER (Opciones de subir/obtener)
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insert_photo, color: Colors.white70, size: 40),
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
              ],
            ),
    );
  }
}
