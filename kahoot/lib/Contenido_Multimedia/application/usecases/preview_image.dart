import '../../domain/repositories/image_repository.dart';

class PreviewImage {
  final ImageRepository repository;

  PreviewImage(this.repository);

  Future<List<int>> call(String idOrUrl) async {
    return await repository.previewImage(idOrUrl);
  }
}
