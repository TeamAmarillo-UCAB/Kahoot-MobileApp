// Archivo: Contenido_Multimedia/application/usecases/download_image.dart

import '../../domain/repositories/image_repository.dart';

class DownloadImage {
  final ImageRepository repository;

  DownloadImage(this.repository);

  // ⬅️ Se corrige el tipo de retorno a List<int> para devolver los bytes de la imagen.
  Future<List<int>> call(String idOrUrl) async {
    // La capa de aplicación simplemente llama al repositorio
    return await repository.getImage(idOrUrl);
  }
}
