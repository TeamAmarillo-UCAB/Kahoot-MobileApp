// Archivo: lib/Contenido_Multimedia/infrastructure/datasource/image_datasource_impl.dart

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import '../../domain/entities/media_file.dart';
import '../../domain/datasource/image_datasource.dart';

const uuid = Uuid();

// Bytes de un GIF 1x1 transparente para el mock de descarga
final List<int> _transparentGifBytes = Uint8List.fromList([
  0x47,
  0x49,
  0x46,
  0x38,
  0x39,
  0x61,
  0x01,
  0x00,
  0x01,
  0x00,
  0x80,
  0x00,
  0x00,
  0xff,
  0xff,
  0xff,
  0x00,
  0x00,
  0x00,
  0x21,
  0xf9,
  0x04,
  0x01,
  0x00,
  0x00,
  0x00,
  0x00,
  0x2c,
  0x00,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x01,
  0x00,
  0x00,
  0x02,
  0x02,
  0x44,
  0x01,
  0x00,
  0x3b,
]);

class ImageDatasourceImpl implements ImageDataSource {
  final Dio dio = Dio();
  final bool isMocking = true;

  @override
  Future<Map<String, dynamic>> uploadImage(MediaFile file) async {
    if (isMocking) {
      await Future.delayed(const Duration(seconds: 2));
      final newUuid = uuid.v4();

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
      // Lógica de API real para POST
      throw UnimplementedError('Real API POST is not implemented yet.');
    }
  }

  @override
  Future<List<int>> getImage(String idOrUrl) async {
    if (isMocking) {
      await Future.delayed(const Duration(milliseconds: 500));
      print('📥 [MOCK IN-PLACE] Descarga simulada para ID/URL: $idOrUrl');
      return _transparentGifBytes;
    } else {
      // Lógica REAL de la API (GET)
      try {
        const String apiBaseUrl = 'https://tu-api.com';
        final url = idOrUrl.startsWith('http')
            ? idOrUrl
            : '$apiBaseUrl/media/$idOrUrl';

        final response = await dio.get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );

        if (response.statusCode == 200) {
          return response.data as List<int>;
        } else {
          throw Exception(
            'Failed to download image: Status ${response.statusCode}',
          );
        }
      } on DioException catch (e) {
        throw Exception('Download failed: ${e.message}');
      }
    }
  }
}
