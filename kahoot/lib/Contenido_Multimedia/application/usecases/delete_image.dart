import '../../domain/repositories/image_repository.dart';

class DeleteImage {
  final ImageRepository repository;

  DeleteImage(this.repository);

  Future<void> call(String url) async {
    return await repository.deleteImage(url);
  }
}