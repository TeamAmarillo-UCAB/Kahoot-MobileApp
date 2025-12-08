import '../entities/media_resource.dart';

abstract class MediaResourceRepository {
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file);

  Future<List<String>> getMediaResource(String idOrUrl);

  Future<List<int>> previewMediaResource(String idOrUrl);

  Future<void> deleteMediaResource(String idOrUrl);
}
