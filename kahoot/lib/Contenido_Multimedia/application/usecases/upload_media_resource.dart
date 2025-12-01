import '../../domain/repositories/media_resource_repository.dart';
import '../../domain/entities/media_resource.dart';

class UploadMediaResource {
  final MediaResourceRepository repository;

  UploadMediaResource(this.repository);

  Future<Map<String, dynamic>> call(MediaResource file) async {
    return await repository.uploadMediaResource(file);
  }
}
