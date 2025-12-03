import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'package:http/http.dart' show MediaType;
import '../../domain/entities/media_resource.dart';
import '../../domain/datasource/media_resource_datasource.dart';

const uuid = Uuid();

class MediaResourceDatasourceImpl implements MediaResourceDataSource {
  //Instancia de Dio para los requests
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  //Booleano que es true si la subida se hace con un mock y no con un post
  final bool isUploadMocking = true;

  //Almacén de bytes de la imagen que el usuario ha seleccionado
  List<int>? _lastUploadedMockBytes;

  //Id de referencia de la imagen simulada
  String? _lastUploadedMockId;

  @override
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file) async {
    //VERIFICAR UPLOADMOCKING SI ES NECESARIO
    if (isUploadMocking) {
      await Future.delayed(const Duration(seconds: 2));
      final newUuid = uuid.v4();

      //Bytes del archivo subido
      _lastUploadedMockBytes = file.bytes;
      //Crea un Uuid para la imagen
      _lastUploadedMockId = newUuid;

      print(
        'Archivo mock subido (${file.name}). Guardando en cache mock con ID: $newUuid',
      );

      //Mapa de JSON
      return {
        "id": newUuid,
        "data": {
          "type": "Buffer",
          "data": file.bytes.sublist(
            0,
            file.bytes.length > 10 ? 10 : file.bytes.length,
          ),
        },
        "mimeType": file.mimeType ?? "application/octet-stream",
        "size": file.bytes.length,
        "originalName": file.name,
        "createdAt": DateTime.now().toIso8601String(),
      };
    } else {
      // Esto es para cuando la API esté lista
      final path = '/media/upload';

      // Conversión de  MediaResource a FormData
      final multipartFile = MultipartFile.fromBytes(
        Uint8List.fromList(file.bytes),
        filename: file.name,
        contentType: file.mimeType != null
            ? MediaType.parse(file.mimeType!)
            : null,
      );

      //Request body
      final formData = FormData.fromMap({'file': multipartFile});

      try {
        //solicitud
        final response = await dio.post(path, data: formData);

        //Respuesta 201
        if (response.statusCode == 201) {
          // Devuelve la respuesta
          return response.data as Map<String, dynamic>;
        } else {
          throw Exception(
            'Error de subida. Status Code: ${response.statusCode}',
          );
        }
      } on DioException catch (e) {
        //Error 400
        if (e.response?.statusCode == 400) {
          throw Exception('400 Bad Request: Datos de slide inválidos.');
        }
        //Error 404
        if (e.response?.statusCode == 404) {
          throw Exception(
            '404 Not Found: El Kahoot no existe o no es accesible.',
          );
        }
        throw Exception('Error de red/conexión: ${e.message}');
      }
    }
  }

  @override
  Future<List<String>> getMediaResource(String idOrUrl) async {
    const int count = 16; //Número de imágenes
    const int width = 150; //Ancho de las imágenes
    const int height = 150; //Alto de las imágenes

    //API de prueba
    const String baseUrl = 'https://picsum.photos';

    final List<String> mediaResourcesUrls = [];

    //Obtiene las URL de las imágenes extraídas de la API de prueba
    for (int i = 0; i < count; i++) {
      final randomId = i + 10;
      final url = '$baseUrl/id/$randomId/$width/$height';
      mediaResourcesUrls.add(url);
    }

    print('Generadas ${mediaResourcesUrls.length} URLs de imágenes de la API.');
    //Retorna las URLs de las imágenes de la API
    return mediaResourcesUrls;
  }

  @override
  Future<List<int>> previewMediaResource(String idOrUrl) async {
    //Si hay un archivo subido ya, lo muestra
    if (idOrUrl == _lastUploadedMockId && _lastUploadedMockBytes != null) {
      print(
        'Vista Previa: Devolviendo bytes del archivo subido: $_lastUploadedMockId',
      );
      return _lastUploadedMockBytes!;
    }

    const int defaultWidth = 300; //Ancho de vista previa
    const int defaultHeight = 300; //Alto de vista previa
    //Llamada a URL si no hay imagen subida para preview
    final urlToFetch = idOrUrl.startsWith('http')
        ? idOrUrl
        : 'https://picsum.photos/$defaultWidth/$defaultHeight';

    try {
      print('🌐 Descargando imagen para vista previa desde: $urlToFetch');

      final response = await dio.get(
        urlToFetch,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return response.data
            as List<int>; //Devuelve la respuesta de la URL como lista de bytes
      } else {
        throw Exception(
          'Failed to download for preview: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('Error de Dio en Preview: ${e.message}');
      throw Exception('Preview failed: ${e.message}');
    }
  }

  @override
  Future<void> deleteMediaResource(String id) async {
    //USA EL MOCK DE LA SUBIDAAAAAAAAAAAAAAAAAAA RECORDARRRR
    if (isUploadMocking) {
      await Future.delayed(const Duration(milliseconds: 500));

      //Elimina el mock (imagen subida o extraída)
      if (id == _lastUploadedMockId) {
        _lastUploadedMockBytes = null;
        _lastUploadedMockId = null;
      }

      print('Eliminación simulada y cache mock limpiado para ID: $id');

      return;
    } else {
      // Para cuando esté lista la API
      final path = '/media/$id';

      try {
        // Solicitud
        final response = await dio.delete(path);

        // Response 200 (eliminado exitosamente)
        if (response.statusCode == 200) {
          print('Eliminación real exitosa para ID: $id');
          return;
        } else {
          throw Exception(
            'Failed to delete media resource: Status ${response.statusCode}',
          );
        }
      } on DioException catch (e) {
        // Error 404
        if (e.response?.statusCode == 404) {
          throw Exception(
            '404 Not Found: El Kahoot no existe o no es accesible.',
          );
        }

        // Error HTTP
        if (e.response != null) {
          throw Exception(
            'Delete failed (HTTP ${e.response!.statusCode}): ${e.response!.statusMessage}',
          );
        }
        // Error de red
        throw Exception('Delete failed (Network/Connection): ${e.message}');
      }
    }
  }
}
