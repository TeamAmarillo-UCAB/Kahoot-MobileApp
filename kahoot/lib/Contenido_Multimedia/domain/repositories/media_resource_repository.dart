// Archivo: lib/domain/repositories/image_repository.dart

import '../entities/media_resource.dart';

abstract class MediaResourceRepository {
  // Para la subida (Upload)
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file);

  // Para la descarga (Download/Get). Retorna List<int> (bytes genéricos).
  Future<List<String>> getMediaResource(String idOrUrl);

  Future<List<int>> previewMediaResource(String idOrUrl);

  Future<void> deleteMediaResource(String idOrUrl);
}
