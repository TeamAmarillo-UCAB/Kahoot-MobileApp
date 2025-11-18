import '../entities/slide.dart';

abstract class SlideRepository {
  Future<void> createSlide(int id, String content, int points, int timeLimit, String answer, bool isCorrect, String urlImage, String type);
  Future<void> updateSlide(Slide slide);
  Future<void> deleteSlide(String id);
}