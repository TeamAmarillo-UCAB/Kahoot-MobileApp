import '../../domain/entities/question.dart';

class ValidationError implements Exception {
  final String message;
  ValidationError(this.message);
  @override
  String toString() => message;
}

void validateKahootInput({
  required String authorId,
  required String title,
  required String visibility,
  required String themeId,
  required List<Question> questions,
}) {
  if (title.trim().isEmpty) {
    throw ValidationError('El título es requerido.');
  }
  if (authorId.trim().isEmpty) {
    throw ValidationError('El autor es requerido.');
  }
  if (visibility != 'public' && visibility != 'private') {
    throw ValidationError('La visibilidad debe ser "public" o "private".');
  }
  if (themeId.trim().isEmpty) {
    throw ValidationError('El tema es requerido.');
  }
  for (final q in questions) {
    validateQuestion(q);
  }
}

void validateQuestion(Question q) {
  if (q.title.trim().isEmpty) {
    throw ValidationError('Cada pregunta debe tener un título.');
  }
  if (q.timeLimitSeconds <= 0) {
    throw ValidationError('La pregunta debe tener un tiempo límite mayor a 0.');
  }
  if (q.points < 0) {
    throw ValidationError('Los puntos no pueden ser negativos.');
  }
  if (q.answer.isEmpty) {
    throw ValidationError('Cada pregunta debe tener al menos una respuesta.');
  }
  final hasCorrect = q.answer.any((a) => a.isCorrect);
  if (!hasCorrect) {
    throw ValidationError('Debe existir al menos una respuesta correcta.');
  }
}
