// Archivo: lib/domain/repositories/image_repository.dart

import '../entities/media_file.dart';

abstract class ImageRepository {
  // Para la subida (Upload)
  Future<Map<String, dynamic>> uploadImage(MediaFile file);

  // Para la descarga (Download/Get). Retorna List<int> (bytes genéricos).
  Future<List<int>> getImage(String idOrUrl);
}
