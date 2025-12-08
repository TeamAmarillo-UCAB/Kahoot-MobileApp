import '../../domain/repositories/media_resource_repository.dart';

class DeleteMediaResource {
  final MediaResourceRepository repository;
  DeleteMediaResource(this.repository);

  Future<void> call(String idOrUrl) async {
    return await repository.deleteMediaResource(idOrUrl);
  }
}
