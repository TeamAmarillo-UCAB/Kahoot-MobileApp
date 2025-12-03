import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/kahoot/get_all_kahoots.dart';
import '../../domain/entities/kahoot.dart';

class KahootListState extends Equatable {
  final bool loading;
  final List<Kahoot> kahoots;
  final String? error;

  const KahootListState._({required this.loading, required this.kahoots, this.error});

  const KahootListState.loading() : this._(loading: true, kahoots: const [], error: null);
  const KahootListState.loaded(List<Kahoot> data) : this._(loading: false, kahoots: data, error: null);
  const KahootListState.error(String err) : this._(loading: false, kahoots: const [], error: err);

  @override
  List<Object?> get props => [loading, kahoots, error];
}

class KahootListCubit extends Cubit<KahootListState> {
  final GetAllKahoots getAllKahoots;

  KahootListCubit({required this.getAllKahoots}) : super(const KahootListState.loading());

  Future<void> load() async {
    emit(const KahootListState.loading());
    final result = await getAllKahoots();
    if (result.isSuccessful()) {
      emit(KahootListState.loaded(result.getValue()));
    } else {
      // Mostrar un mensaje amigable para errores no-404
      emit(const KahootListState.error('No se pudieron cargar tus kahoots. Intenta más tarde.'));
    }
  }
}
