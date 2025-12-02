import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../application/usecases/kahoot/create_kahoot.dart';
import '../../application/usecases/kahoot/update_kahoot.dart';
import '../../application/utils/validators.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/kahoot.dart';
import '../../domain/entities/question.dart';

enum EditorStatus { idle, saving, saved, error }

class KahootEditorState extends Equatable {
  final String authorId;
  final String title;
  final String description;
  final String coverImageId;
  final String visibility; // 'public'|'private'
  final String themeId;
  final List<Question> questions;
  final EditorStatus status;
  final String? errorMessage;

  const KahootEditorState({
    required this.authorId,
    required this.title,
    required this.description,
    required this.coverImageId,
    required this.visibility,
    required this.themeId,
    required this.questions,
    required this.status,
    this.errorMessage,
  });

  KahootEditorState copyWith({
    String? authorId,
    String? title,
    String? description,
    String? coverImageId,
    String? visibility,
    String? themeId,
    List<Question>? questions,
    EditorStatus? status,
    String? errorMessage,
  }) => KahootEditorState(
        authorId: authorId ?? this.authorId,
        title: title ?? this.title,
        description: description ?? this.description,
        coverImageId: coverImageId ?? this.coverImageId,
        visibility: visibility ?? this.visibility,
        themeId: themeId ?? this.themeId,
        questions: questions ?? this.questions,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [authorId, title, description, coverImageId, visibility, themeId, questions, status, errorMessage];
}

class KahootEditorCubit extends Cubit<KahootEditorState> {
  final CreateKahoot createKahootUseCase;
  final UpdateKahoot updateKahootUseCase;

  KahootEditorCubit({
    required this.createKahootUseCase,
    required this.updateKahootUseCase,
    String? initialAuthorId,
  }) : super(KahootEditorState(
          authorId: initialAuthorId ?? '',
          title: '',
          description: '',
          coverImageId: '',
          visibility: 'private',
          themeId: '',
          questions: const [],
          status: EditorStatus.idle,
        ));

  void setAuthor(String id) => emit(state.copyWith(authorId: id));
  void setTitle(String v) => emit(state.copyWith(title: v));
  void setDescription(String v) => emit(state.copyWith(description: v));
  void setCoverImage(String v) => emit(state.copyWith(coverImageId: v));
  void setVisibility(String v) => emit(state.copyWith(visibility: v));
  void setTheme(String v) => emit(state.copyWith(themeId: v));

  void addQuestion(Question q) => emit(state.copyWith(questions: List<Question>.from(state.questions)..add(q)));
  void updateQuestion(int index, Question q) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<Question>.from(state.questions);
    updated[index] = q;
    emit(state.copyWith(questions: updated));
  }
  void removeQuestion(int index) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<Question>.from(state.questions)..removeAt(index);
    emit(state.copyWith(questions: updated));
  }

  void addAnswer(int qIndex, Answer a) {
    if (qIndex < 0 || qIndex >= state.questions.length) return;
    final q = state.questions[qIndex];
    final newAnswers = List<Answer>.from(q.answer)..add(a);
    final updatedQ = Question(
      text: q.text,
      title: q.title,
      mediaId: q.mediaId,
      type: q.type,
      points: q.points,
      timeLimitSeconds: q.timeLimitSeconds,
      answer: newAnswers,
    );
    updateQuestion(qIndex, updatedQ);
  }
  void updateAnswer(int qIndex, int aIndex, Answer a) {
    if (qIndex < 0 || qIndex >= state.questions.length) return;
    final q = state.questions[qIndex];
    if (aIndex < 0 || aIndex >= q.answer.length) return;
    final newAnswers = List<Answer>.from(q.answer);
    newAnswers[aIndex] = a;
    final updatedQ = Question(
      text: q.text,
      title: q.title,
      mediaId: q.mediaId,
      type: q.type,
      points: q.points,
      timeLimitSeconds: q.timeLimitSeconds,
      answer: newAnswers,
    );
    updateQuestion(qIndex, updatedQ);
  }
  void removeAnswer(int qIndex, int aIndex) {
    if (qIndex < 0 || qIndex >= state.questions.length) return;
    final q = state.questions[qIndex];
    if (aIndex < 0 || aIndex >= q.answer.length) return;
    final newAnswers = List<Answer>.from(q.answer)..removeAt(aIndex);
    final updatedQ = Question(
      text: q.text,
      title: q.title,
      mediaId: q.mediaId,
      type: q.type,
      points: q.points,
      timeLimitSeconds: q.timeLimitSeconds,
      answer: newAnswers,
    );
    updateQuestion(qIndex, updatedQ);
  }

  Future<void> saveCreate() async {
    try {
      emit(state.copyWith(status: EditorStatus.saving, errorMessage: null));
      validateKahootInput(
        authorId: state.authorId,
        title: state.title,
        visibility: state.visibility,
        themeId: state.themeId,
        questions: state.questions,
      );
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final result = await createKahootUseCase(
        id,
        state.authorId,
        state.title,
        state.description,
        state.coverImageId,
        state.visibility,
        state.themeId,
        state.questions,
        const <Answer>[],
      );
      if (result.isSuccessful()) {
        emit(state.copyWith(status: EditorStatus.saved));
      } else {
        emit(state.copyWith(status: EditorStatus.error, errorMessage: result.getError().toString()));
      }
    } catch (e) {
      emit(state.copyWith(status: EditorStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> saveUpdate(Kahoot kahoot) async {
    emit(state.copyWith(status: EditorStatus.saving, errorMessage: null));
    final result = await updateKahootUseCase(kahoot);
    if (result.isSuccessful()) {
      emit(state.copyWith(status: EditorStatus.saved));
    } else {
      emit(state.copyWith(status: EditorStatus.error, errorMessage: result.getError().toString()));
    }
  }
}
