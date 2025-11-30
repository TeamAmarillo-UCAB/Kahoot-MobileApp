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
  final Dio dio = Dio();
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
  Future<List<int>> getImage(String idOrUrl) async {
    // Dimensiones para la imagen de Placeholder (ej. 300x200)
    const int width = 300;
    const int height = 200;
    const String loremPicsumUrl = 'https://picsum.photos/$width/$height';

    // ❌ Eliminado el bloque if (isDownloadMocking)

    // --- Lógica de API Real (Usando Placeholder para Prueba) ---
    try {
      final url = loremPicsumUrl;

      print('🌐 Descargando imagen de P L A C E H O L D E R desde: $url');

      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception(
          'Failed to download placeholder image: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ Error de Dio: ${e.message}');
      throw Exception('Placeholder image download failed: ${e.message}');
    }
  }

  // ====================================================================
  // 👁️ PREVIEW IMAGE (SIN CAMBIOS)
  // ====================================================================

  @override
  Future<List<int>> previewImage(String idOrUrl) async {
    // 1. 🥇 PRIORIDAD: Verificar si el ID solicitado coincide con el archivo que acabamos de "subir"
    if (idOrUrl == _lastUploadedMockId && _lastUploadedMockBytes != null) {
      print(
        '👁️ [CACHE MOCK] Vista Previa: Devolviendo bytes del archivo subido: $_lastUploadedMockId',
      );
      return _lastUploadedMockBytes!;
    }

    // 2. 🥈 SEGUNDA OPCIÓN: Usar Lorem Picsum.
    const int width = 300;
    const int height = 200;
    const String loremPicsumUrl = 'https://picsum.photos/$width/$height';

    try {
      final url = loremPicsumUrl;

      print(
        '🌐 Descargando imagen de P L A C E H O L D E R para vista previa desde: $url',
      );

      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception(
          'Failed to download placeholder for preview: Status ${response.statusCode}',
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
