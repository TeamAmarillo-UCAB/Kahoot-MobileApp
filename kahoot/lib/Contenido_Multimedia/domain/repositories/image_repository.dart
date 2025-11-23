import 'package:dartz/dartz.dart';
import '../entities/image.dart';

abstract class ImageRepository {
  Future<void> deleteImage(String url);
  Future<void> downloadImage(String url);
  Future<void> previewImage(String url);
  Future<void> uploadImage(String url);
}