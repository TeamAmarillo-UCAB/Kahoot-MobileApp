import '../../domain/repositories/image_repository.dart';

class UploadImage {
  final ImageRepository repository;

  UploadImage(this.repository);

  Future<void> call(String url) async {
    return await repository.uploadImage(url);
  }
}