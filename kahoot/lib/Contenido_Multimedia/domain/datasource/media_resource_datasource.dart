import '../entities/media_resource.dart';

abstract class MediaResourceDataSource {
  Future<Map<String, dynamic>> uploadMediaResource(MediaResource file);
}
