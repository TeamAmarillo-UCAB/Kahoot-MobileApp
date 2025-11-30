// Archivo: lib/domain/datasource/image_datasource.dart

import '../entities/media_file.dart';

abstract class ImageDataSource {
  // Para la subida
  Future<Map<String, dynamic>> uploadImage(MediaFile file);

  // Para la descarga
  Future<List<String>> getImage(String idOrUrl);

  Future<List<int>> previewImage(String idOrUrl);

  Future<void> deleteImage(String idOrUrl);
}
