import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/delete_kahoot_usecase.dart';

enum DeleteKahootStatus { idle, deleting, deleted, error }

class DeleteKahootState {
  final DeleteKahootStatus status;
  final String? errorMessage;
  const DeleteKahootState({required this.status, this.errorMessage});
}

class DeleteKahootCubit extends Cubit<DeleteKahootState> {
  final DeleteKahootUseCase deleteKahoot;
  DeleteKahootCubit({required this.deleteKahoot}) : super(const DeleteKahootState(status: DeleteKahootStatus.idle));

  Future<void> removeById(String id) async {
    emit(const DeleteKahootState(status: DeleteKahootStatus.deleting));
    final result = await deleteKahoot.call(id);
    if (result.isSuccessful()) {
      emit(const DeleteKahootState(status: DeleteKahootStatus.deleted));
    } else {
      emit(DeleteKahootState(status: DeleteKahootStatus.error, errorMessage: result.getError().toString()));
    }
  }
}
