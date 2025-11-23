import '../../domain/repositories/image_repository.dart';

class DownloadImage {
  final ImageRepository repository;

  DownloadImage(this.repository);

  Future<void> call(String url) async {
    return await repository.downloadImage(url);
  }
}