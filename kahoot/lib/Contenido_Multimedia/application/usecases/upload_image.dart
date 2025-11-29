// Archivo: lib/domain/usecases/upload_image.dart

import '../../domain/repositories/image_repository.dart';
// Importa la entidad de dominio MediaFile
import '../../domain/entities/media_file.dart';

class UploadImage {
  final ImageRepository repository;

  UploadImage(this.repository);

  // ⬅️ Cambia el argumento de String url a MediaFile file
  // ⬅️ Cambia el retorno de Future<void> a Future<Map<String, dynamic>> para devolver la respuesta del servidor (UUID)
  Future<Map<String, dynamic>> call(MediaFile file) async {
    // El caso de uso llama directamente al repositorio con la entidad de dominio
    return await repository.uploadImage(file);
  }
}
