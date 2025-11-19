import '../../../domain/repositories/answer_repository.dart';

class DeleteAnswer{
  final AnswerRepository repository;

  DeleteAnswer(this.repository);
  Future<void> call(int answerId) async {
    return await repository.deleteAnswer(answerId);
  }
}