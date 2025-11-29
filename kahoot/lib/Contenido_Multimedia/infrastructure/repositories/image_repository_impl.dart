// Archivo: lib/data/repositories/image_repository_impl.dart

import '../../domain/repositories/image_repository.dart';
import '../../domain/entities/media_file.dart';
import '../../domain/datasource/image_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  // Dependencia de la interfaz del Datasource
  final ImageDataSource dataSource;

  ImageRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, dynamic>> uploadImage(MediaFile file) async {
    // Delega la llamada de subida al Datasource
    return await dataSource.uploadImage(file);
  }
}
