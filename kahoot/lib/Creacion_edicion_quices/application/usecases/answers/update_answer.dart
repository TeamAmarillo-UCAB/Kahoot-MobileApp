import '../../../domain/entities/answer.dart';
import '../../../domain/repositories/answer_repository.dart';

class UpdateAnswer{
  final AnswerRepository repository;

  UpdateAnswer(this.repository);
  Future<void> call(Answer answer) async {
    return await repository.updateAnswer(answer);
  }
}