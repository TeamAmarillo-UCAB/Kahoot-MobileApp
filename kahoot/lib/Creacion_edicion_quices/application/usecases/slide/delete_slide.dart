import'../../../domain/repositories/slide_repository.dart';

class DeleteSlide{
  final SlideRepository repository;

  DeleteSlide(this.repository);

  Future<void> call(String id) async {
    await repository.deleteSlide(id);
  }
}