import '../../domain/repositories/media_resource_repository.dart';

class PreviewMediaResource {
  final MediaResourceRepository repository;

  PreviewMediaResource(this.repository);

  Future<List<int>> call(String idOrUrl) async {
    return await repository.previewMediaResource(idOrUrl);
  }
}
