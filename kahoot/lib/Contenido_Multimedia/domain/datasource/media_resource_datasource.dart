// Archivo: lib/domain/datasource/image_datasource.dart

import '../entities/media_resource.dart';

abstract class MediaResourceDataSource {
  // Para la subida
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file);

  // Para la descarga
  Future<List<String>> getMediaResource(String idOrUrl);

  Future<List<int>> previewMediaResource(String idOrUrl);

  Future<void> deleteMediaResource(String idOrUrl);
}
