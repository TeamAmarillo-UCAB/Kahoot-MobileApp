// Archivo: lib/domain/repositories/image_repository.dart

import '../entities/media_file.dart';

abstract class ImageRepository {
  // Para la subida (Upload): Espera la entidad de dominio y devuelve la respuesta JSON del servidor
  Future<Map<String, dynamic>> uploadImage(MediaFile file);
}
