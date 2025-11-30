import '../../domain/repositories/image_repository.dart';

class DeleteImage {
  final ImageRepository repository;
  DeleteImage(this.repository);

  Future<void> call(String idOrUrl) async {
    return await repository.deleteImage(idOrUrl);
  }
}
