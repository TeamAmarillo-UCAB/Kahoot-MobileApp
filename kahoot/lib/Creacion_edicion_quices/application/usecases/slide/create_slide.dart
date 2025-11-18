import '../../../domain/repositories/slide_repository.dart';

class CreateSlide{
  final SlideRepository repository;

  CreateSlide(this.repository);

  Future<void> call(int id, String content, int points, int timeLimit, String answer, bool isCorrect, String urlImage, String type) async {
    return await repository.createSlide(id, content, points, timeLimit, answer, isCorrect, urlImage, type);
  }
}