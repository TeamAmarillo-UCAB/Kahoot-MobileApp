// Archivo: lib/Contenido_Multimedia/infrastructure/repositories/image_repository_impl.dart

import '../../domain/repositories/image_repository.dart';
import '../../domain/entities/media_file.dart';
import '../../domain/datasource/image_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageDataSource dataSource;

  ImageRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, dynamic>> uploadImage(MediaFile file) async {
    return await dataSource.uploadImage(file);
  }

  @override
  Future<List<String>> getImage(String idOrUrl) async {
    return await dataSource.getImage(idOrUrl);
  }

  @override
  Future<List<int>> previewImage(String idOrUrl) async {
    return await dataSource.previewImage(idOrUrl);
  }

  @override
  Future<void> deleteImage(String idOrUrl) async {
    return await dataSource.deleteImage(idOrUrl);
  }
}
