// Archivo: Contenido_Multimedia/application/usecases/download_image.dart

import '../../domain/repositories/media_resource_repository.dart';

class GetMediaResource {
  final MediaResourceRepository repository;

  GetMediaResource(this.repository);

  // ⬅️ Se corrige el tipo de retorno a List<int> para devolver los bytes de la imagen.
  Future<List<String>> call(String idOrUrl) async {
    // La capa de aplicación simplemente llama al repositorio
    return await repository.getMediaResource(idOrUrl);
  }
}
