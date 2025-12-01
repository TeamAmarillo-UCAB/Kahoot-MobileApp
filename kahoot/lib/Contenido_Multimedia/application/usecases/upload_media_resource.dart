// Archivo: lib/domain/usecases/upload_image.dart

import '../../domain/repositories/media_resource_repository.dart';
// Importa la entidad de dominio MediaFile
import '../../domain/entities/media_resource.dart';

class UploadMediaResource {
  final MediaResourceRepository repository;

  UploadMediaResource(this.repository);

  // ⬅️ Cambia el argumento de String url a MediaFile file
  // ⬅️ Cambia el retorno de Future<void> a Future<Map<String, dynamic>> para devolver la respuesta del servidor (UUID)
  Future<Map<String, dynamic>> call(MediaResource file) async {
    // El caso de uso llama directamente al repositorio con la entidad de dominio
    return await repository.uploadMediaResource(file);
  }
}
