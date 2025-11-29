// Archivo: lib/data/datasources/image_datasource.dart

import '../../domain/entities/media_file.dart';

abstract class ImageDataSource {
  // Firma idéntica al repositorio para que la delegación sea limpia
  Future<Map<String, dynamic>> uploadImage(MediaFile file);
}
