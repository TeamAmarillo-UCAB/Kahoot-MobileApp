import 'package:dartz/dartz.dart';
import '../entities/image.dart';

abstract class ImageDataSource {
  Future<Either<void>>> deleteImage(String url);
  Future<Image> downloadImage(String url);
  Future<Image> previewImage(String url);
  Future<void> uploadImage(String url);
}