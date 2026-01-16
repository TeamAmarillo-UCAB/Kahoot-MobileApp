import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/kahoot/get_all_kahoots.dart';
import '../../application/usecases/kahoot/get_kahoots_by_author.dart';
import '../../application/usecases/kahoot/get_kahoot_by_kahoot_id.dart';
import '../../domain/entities/kahoot.dart';

class KahootListState extends Equatable {
  final bool loading;
  final List<Kahoot> kahoots;
  final String? error;
  final String? selectedCategory;

  const KahootListState._({required this.loading, required this.kahoots, this.error, this.selectedCategory});

  const KahootListState.loading() : this._(loading: true, kahoots: const [], error: null, selectedCategory: null);
  const KahootListState.loaded(List<Kahoot> data, {String? selectedCategory}) : this._(loading: false, kahoots: data, error: null, selectedCategory: selectedCategory);
  const KahootListState.error(String err, {String? selectedCategory}) : this._(loading: false, kahoots: const [], error: err, selectedCategory: selectedCategory);

  @override
  List<Object?> get props => [loading, kahoots, error, selectedCategory];
}

class KahootListCubit extends Cubit<KahootListState> {
  final GetAllKahoots getAllKahoots;
  final GetKahootsByAuthor? getByAuthor;
  final String? authorId;
  final GetKahootByKahootId? getByKahootId;
  final String? kahootId;

  KahootListCubit({required this.getAllKahoots, this.getByAuthor, this.authorId, this.getByKahootId, this.kahootId}) : super(const KahootListState.loading());

  Future<void> load() async {
    emit(const KahootListState.loading());
    final result = (getByKahootId != null && (kahootId != null && kahootId!.isNotEmpty))
        ? await getByKahootId!.call(kahootId!)
        : (getByAuthor != null && (authorId != null && authorId!.isNotEmpty))
            ? await getByAuthor!.call(authorId!)
            : await getAllKahoots();
    if (result.isSuccessful()) {
      final value = result.getValue();
      // El usecase por id devuelve Kahoot?; normalizar a lista
      final list = value is Kahoot ? <Kahoot>[value] : (value as List<Kahoot>);
      emit(KahootListState.loaded(list, selectedCategory: state.selectedCategory));
    } else {
      // Mostrar un mensaje amigable para errores no-404
      emit(KahootListState.error('No se pudieron cargar tus kahoots. Intenta más tarde.', selectedCategory: state.selectedCategory));
    }
  }

  Future<void> loadWithKahootId(String id) async {
    if (getByKahootId == null) {
      await load();
      return;
    }
    emit(const KahootListState.loading());
    final result = await getByKahootId!.call(id);
    if (result.isSuccessful()) {
      final Kahoot? value = result.getValue();
      final list = value == null ? <Kahoot>[] : <Kahoot>[value];
      emit(KahootListState.loaded(list, selectedCategory: state.selectedCategory));
    } else {
      emit(KahootListState.error('No se pudieron cargar tus kahoots. Intenta más tarde.', selectedCategory: state.selectedCategory));

    }
  }

  void selectCategory(String nombre) {
    emit(KahootListState._(
      loading: state.loading,
      kahoots: state.kahoots,
      error: state.error,
      selectedCategory: nombre,
    ));
  }
}
