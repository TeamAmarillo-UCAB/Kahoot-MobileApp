import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:http/http.dart' show MediaType;
import '../../domain/entities/media_resource.dart';
import '../../domain/datasource/media_resource_datasource.dart';
import '../../../core/auth_state.dart';
import '../../../config/api_config.dart';

class MediaResourceDatasourceImpl implements MediaResourceDataSource {
  final Dio dio;
  MediaResourceDatasourceImpl({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          ) {
    // Configuración del Interceptor para el Token
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Obtener token
          final token = AuthState.token.value;
          options.baseUrl = ApiConfig().baseUrl;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file) async {
    const path = '/media/upload';

    String fileName = file.name.isNotEmpty ? file.name : 'upload.png';
    if (!fileName.contains('.')) {
      fileName += '.png';
    }

    final multipartFile = MultipartFile.fromBytes(
      file.bytes,
      filename: fileName,
      contentType: MediaType.parse(file.mimeType ?? 'image/png'),
    );

    final formData = FormData.fromMap({'file': multipartFile});
    try {
      final response = await dio.post(path, data: formData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
