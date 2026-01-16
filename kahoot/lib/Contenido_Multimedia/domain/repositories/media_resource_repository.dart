import '../entities/media_resource.dart';

abstract class MediaResourceRepository {
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file);
}
