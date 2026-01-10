import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../application/get_my_khoots_usecase.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../core/result.dart';

enum LibraryListStatus { initial, loading, loaded, error }

class LibraryListState extends Equatable {
  final LibraryListStatus status;
  final List<Kahoot> items;
  final String? errorMessage;

  const LibraryListState({
    required this.status,
    required this.items,
    this.errorMessage,
  });

  LibraryListState copyWith({
    LibraryListStatus? status,
    List<Kahoot>? items,
    String? errorMessage,
  }) => LibraryListState(
        status: status ?? this.status,
        items: items ?? this.items,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, items, errorMessage];
}

class LibraryListCubit extends Cubit<LibraryListState> {
  final GetMyKhootsUseCase getMyKhoots;

  LibraryListCubit({required this.getMyKhoots})
      : super(const LibraryListState(status: LibraryListStatus.initial, items: []));

  Future<void> load() async {
    emit(state.copyWith(status: LibraryListStatus.loading, errorMessage: null));
    try {
      final Result<List<Kahoot>> result = await getMyKhoots.call();
      if (result.isSuccessful()) {
        final data = result.getValue();
        emit(state.copyWith(status: LibraryListStatus.loaded, items: data));
      } else {
        emit(state.copyWith(status: LibraryListStatus.error, errorMessage: result.getError().toString()));
      }
    } catch (e) {
      emit(state.copyWith(status: LibraryListStatus.error, errorMessage: e.toString()));
    }
  }
}
