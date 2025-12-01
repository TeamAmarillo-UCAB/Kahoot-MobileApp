import '../../domain/repositories/media_resource_repository.dart';

class GetMediaResource {
  final MediaResourceRepository repository;

  GetMediaResource(this.repository);

  Future<List<String>> call(String idOrUrl) async {
    return await repository.getMediaResource(idOrUrl);
  }
}
