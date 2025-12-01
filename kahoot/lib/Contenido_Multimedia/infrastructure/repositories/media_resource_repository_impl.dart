// Archivo: lib/Contenido_Multimedia/infrastructure/repositories/image_repository_impl.dart

import '../../domain/repositories/media_resource_repository.dart';
import '../../domain/entities/media_resource.dart';
import '../../domain/datasource/media_resource_datasource.dart';

class MediaResourceRepositoryImpl implements MediaResourceRepository {
  final MediaResourceDataSource dataSource;

  MediaResourceRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file) async {
    return await dataSource.uploadMediaResource(file);
  }

  @override
  Future<List<String>> getMediaResource(String idOrUrl) async {
    return await dataSource.getMediaResource(idOrUrl);
  }

  @override
  Future<List<int>> previewMediaResource(String idOrUrl) async {
    return await dataSource.previewMediaResource(idOrUrl);
  }

  @override
  Future<void> deleteMediaResource(String idOrUrl) async {
    return await dataSource.deleteMediaResource(idOrUrl);
  }
}
