// Archivo: lib/data/datasources/image_datasource_impl.dart

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/media_file.dart'; // Importa la entidad de dominio
import '../../domain/datasource/image_datasource.dart'; // Implementa la interfaz

// Generador de UUID para el mock
const uuid = Uuid();

class ImageDatasourceImpl implements ImageDataSource {
  final Dio dio = Dio();

  // ⚠️ VARIABLE DE CONTROL: Establécela en true para hacer mock, false para usar la API real
  final bool isMocking = true; // Establecer en 'true' para probar el mock

  @override
  Future<Map<String, dynamic>> uploadImage(MediaFile file) async {
    // =========================================================
    // Bloque 1: Lógica del Mock Local
    // =========================================================
    if (isMocking) {
      // Simular Latencia
      await Future.delayed(const Duration(seconds: 2));

      // Simular Validación (Ejemplo: error 400 Bad Request)
      if (file.bytes.length > 5 * 1024 * 1024) {
        throw Exception('400 Bad Request: El archivo excede el límite de 5MB.');
      }

      final newUuid = uuid.v4();
      print(
        '✅ [MOCK IN-PLACE] Subida simulada exitosamente para: ${file.name}',
      );

      // Devolver la respuesta simulada
      return {
        "id": newUuid,
        "type": "image",
        "mimeType": file.mimeType ?? "application/octet-stream",
        "url": "https://mock-api.com/media/$newUuid",
        "size": file.bytes.length,
        "createdAt": DateTime.now().toIso8601String(),
      };
    }
    // =========================================================
    // Fin Bloque Mock
    // =========================================================

    // ---------------------------------------------------------
    // Bloque 2: Lógica REAL de la API (Comentada o Ejecutada)
    // ---------------------------------------------------------

    // Si isMocking es false, el código continúa aquí.

    // 1. Crea MultipartFile y FormData a partir de la entidad MediaFile
    MultipartFile fileToUpload = MultipartFile.fromBytes(
      file.bytes,
      filename: file.name,
      contentType: file.mimeType != null
          ? MediaType.parse(file.mimeType!)
          : null,
    );

    FormData formData = FormData.fromMap({'file': fileToUpload});

    try {
      const String apiBaseUrl = 'https://tu-api.com';
      const String requestPath = '/media/upload';

      // ⚠️ Llamada a la API real
      final Response response = await dio.request(
        '$apiBaseUrl$requestPath',
        options: Options(method: 'POST'),
        data: formData,
      );

      // Manejar la respuesta exitosa (201 Created)
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        // Manejar otros códigos de éxito (ej. 200)
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error:
              'Failed to upload image with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Manejar errores de API reales
      if (e.response?.statusCode == 404) {
        throw Exception('404 Not Found: El endpoint no existe.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('400 Bad Request: Datos de slide inválidos.');
      }
      throw e;
    }
  }

  // Puedes dejar deleteImage sin mock si no lo estás probando, o añadir el mismo patrón.
  @override
  Future<void> deleteImage(String id) async {
    // Si necesitas mockear la eliminación, sigue el mismo patrón:
    if (isMocking) {
      await Future.delayed(const Duration(milliseconds: 500));
      print(
        '🗑️ [MOCK IN-PLACE] Eliminación simulada exitosamente para ID: $id',
      );
      return;
    }

    // Lógica real de eliminación:
    try {
      const String apiBaseUrl = 'https://tu-api.com';
      const String requestPath = '/media/';

      await dio.delete(
        '$apiBaseUrl$requestPath$id',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on DioException catch (e) {
      throw e;
    }
  }
}
