// Archivo: lib/Contenido_Multimedia/infrastructure/datasource/image_datasource_impl.dart

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import '../../domain/entities/media_file.dart';
import '../../domain/datasource/image_datasource.dart';

const uuid = Uuid();

// ❌ Se elimina la definición de _transparentGifBytes, ya no es necesaria.

class ImageDatasourceImpl implements ImageDataSource {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(
        seconds: 10,
      ), // Límite para establecer la conexión
      receiveTimeout: const Duration(
        seconds: 10,
      ), // Límite para recibir la respuesta
    ),
  );
  // Bandera para subir (usamos MOCK para devolver bytes inmediatamente)
  final bool isUploadMocking = true;
  // Esta bandera ahora es irrelevante para getImage/previewImage, pero la mantenemos.
  final bool isDownloadMocking = false;

  // Cache temporal para la subida
  List<int>? _lastUploadedMockBytes;
  String? _lastUploadedMockId;

  // ====================================================================
  // ⬆️ UPLOAD IMAGE (SIN CAMBIOS)
  // ====================================================================

  @override
  Future<Map<String, dynamic>> uploadImage(MediaFile file) async {
    if (isUploadMocking) {
      await Future.delayed(const Duration(seconds: 2));
      final newUuid = uuid.v4();

      _lastUploadedMockBytes = file.bytes;
      _lastUploadedMockId = newUuid;
      print(
        '⬆️ [MOCK] Archivo subido (${file.name}). Guardando en cache mock con ID: $newUuid',
      );

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
      throw UnimplementedError('Real API POST is not implemented yet.');
    }
  }

  // ====================================================================
  // 📥 GET IMAGE (DESCARGA COMPLETA - AHORA SOLO API REAL)
  // ====================================================================

  @override
  // 🚨 ASUMIMOS QUE LA INTERFAZ HA CAMBIADO A: Future<List<String>> getImage(String idOrUrl)
  Future<List<String>> getImage(String idOrUrl) async {
    const int count = 16; // Queremos 10 imágenes
    const int width = 150;
    const int height = 150;

    // URL base de Lorem Picsum
    const String baseUrl = 'https://picsum.photos';

    final List<String> imageUrls = [];

    // Generamos 10 URLs diferentes usando un ID aleatorio (seed)
    // El 'seed' (número después de /id/) asegura una imagen diferente.
    for (int i = 0; i < count; i++) {
      // Usamos i + 100 para obtener un rango diferente de fotos
      final randomId = i + 10;
      final url = '$baseUrl/id/$randomId/$width/$height';
      imageUrls.add(url);
    }

    print('🌐 Generadas ${imageUrls.length} URLs de imágenes aleatorias.');

    // Devolvemos la lista de URLs para que la UI pueda mostrarlas.
    return imageUrls;
  }
  // ====================================================================
  // 👁️ PREVIEW IMAGE (SIN CAMBIOS)
  // ====================================================================

  @override
  Future<List<int>> previewImage(String idOrUrl) async {
    // 1. Prioridad: Verificar si el ID solicitado coincide con el archivo que acabamos de "subir"
    if (idOrUrl == _lastUploadedMockId && _lastUploadedMockBytes != null) {
      print(
        '👁️ [CACHE MOCK] Vista Previa: Devolviendo bytes del archivo subido: $_lastUploadedMockId',
      );
      return _lastUploadedMockBytes!;
    }

    // 2. Segunda Opción: Si es una URL (Descarga/Selección), usar Dio.
    // Usamos el idOrUrl directamente, ya que en el flujo de selección es la URL completa.

    const int defaultWidth = 300;
    const int defaultHeight = 300;
    final urlToFetch = idOrUrl.startsWith('http')
        ? idOrUrl
        : 'https://picsum.photos/$defaultWidth/$defaultHeight'; // Fallback si es un ID desconocido

    try {
      print('🌐 Descargando imagen para vista previa desde: $urlToFetch');

      final response = await dio.get(
        urlToFetch,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception(
          'Failed to download for preview: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ Error de Dio en Preview: ${e.message}');
      throw Exception('Preview failed: ${e.message}');
    }
  }

  @override
  Future<void> deleteImage(String id) async {
    if (isUploadMocking) {
      // Simulamos un retraso para la eliminación
      await Future.delayed(const Duration(milliseconds: 500));

      // Si el ID es el último subido, lo eliminamos de la caché mock
      if (id == _lastUploadedMockId) {
        _lastUploadedMockBytes = null;
        _lastUploadedMockId = null;
      }

      print(
        '🗑️ [MOCK] Eliminación simulada y cache mock limpiado para ID: $id',
      );
      // En el mock, simplemente no devolvemos nada (Future<void>)
      return;
    } else {
      // Lógica REAL de la API (DELETE)
      try {
        const String apiBaseUrl = 'https://tu-api.com';
        final url = '$apiBaseUrl/media/$id';

        final response = await dio.delete(url);

        if (response.statusCode == 200) {
          print('✅ Eliminación real exitosa para ID: $id');
          return;
        } else {
          throw Exception(
            'Failed to delete image: Status ${response.statusCode}',
          );
        }
      } on DioException catch (e) {
        // 404 Not Found: El Kahoot no existe o no es accesible.
        throw Exception('Delete failed: ${e.message}');
      }
    }
  }
}
