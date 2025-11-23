import '../../domain/repositories/image_repository.dart';

class PreviewImage {
  final ImageRepository repository;

  PreviewImage(this.repository);

  Future<void> call(String url) async {
    return await repository.previewImage(url);
  }
}