import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/update_my_kahoot_usecase.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../Creacion_edicion_quices/domain/entities/question.dart';
import '../../../Creacion_edicion_quices/domain/entities/answer.dart';

enum UpdateMyKahootStatus { idle, submitting, success, error }

class UpdateMyKahootState {
  final UpdateMyKahootStatus status;
  final String? errorMessage;
  const UpdateMyKahootState({required this.status, this.errorMessage});
}

class UpdateMyKahootCubit extends Cubit<UpdateMyKahootState> {
  final UpdateMyKahootUseCase updateUseCase;
  UpdateMyKahootCubit({required this.updateUseCase}) : super(const UpdateMyKahootState(status: UpdateMyKahootStatus.idle));

  Future<void> submit(Kahoot k) async {
    emit(const UpdateMyKahootState(status: UpdateMyKahootStatus.submitting));
    final res = await updateUseCase.call(
      k.kahootId,
      k.title,
      k.description,
      k.image,
      k.visibility.toShortString(),
      'published',
      k.theme,
      k.question,
      k.question.expand<Answer>((q) => q.answer).toList(),
    );
    if (res.isSuccessful()) {
      emit(const UpdateMyKahootState(status: UpdateMyKahootStatus.success));
    } else {
      emit(UpdateMyKahootState(status: UpdateMyKahootStatus.error, errorMessage: res.getError().toString()));
    }
  }
}
