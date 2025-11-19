import '../../../domain/entities/answer.dart';
import '../../../domain/repositories/answer_repository.dart';

class GetAnswers{
  final AnswerRepository repository;

  GetAnswers(this.repository);
  Future<List<Answer>> call() async {
    return await repository.getAnswers();
  }
}