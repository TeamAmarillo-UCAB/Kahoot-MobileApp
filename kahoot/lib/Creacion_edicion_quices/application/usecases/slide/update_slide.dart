import '../../../domain/repositories/slide_repository.dart';
import '../../../domain/entities/slide.dart';

class UpdateSlide{
  final SlideRepository repository;

  UpdateSlide(this.repository);

  Future<void> call(Slide slide) async {
    return await repository.updateSlide(slide);
  }
}