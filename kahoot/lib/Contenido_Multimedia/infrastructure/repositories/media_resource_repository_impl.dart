import '../../domain/entities/media_resource.dart';
import '../../domain/repositories/media_resource_repository.dart';
import '../../domain/datasource/media_resource_datasource.dart';

class MediaResourceRepositoryImpl implements MediaResourceRepository {
  final MediaResourceDataSource dataSource;

  MediaResourceRepositoryImpl(this.dataSource);

  @override
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file) {
    return dataSource.uploadMediaResource(file);
  }
}
