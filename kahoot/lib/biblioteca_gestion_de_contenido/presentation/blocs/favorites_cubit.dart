import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/library_repository.dart';
import '../../../core/result.dart';

class FavoritesState extends Equatable {
  final Set<String> favorites;
  final Set<String> loading; // ids currently toggling

  const FavoritesState({this.favorites = const {}, this.loading = const {}});

  FavoritesState copyWith({Set<String>? favorites, Set<String>? loading}) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [favorites, loading];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final KahootRepository repository;
  FavoritesCubit({required this.repository}) : super(const FavoritesState());

  bool isFavorite(String id) => state.favorites.contains(id);
  bool isBusy(String id) => state.loading.contains(id);

  Future<void> toggle(String id) async {
    if (state.loading.contains(id)) return;
    final newLoading = Set<String>.from(state.loading)..add(id);
    emit(state.copyWith(loading: newLoading));

    final bool willFav = !state.favorites.contains(id);
    Result<void> result;
    if (willFav) {
      result = await repository.addKahootToFavorites(id);
    } else {
      result = await repository.removeKahootFromFavorites(id);
    }

    final updatedLoading = Set<String>.from(state.loading)..remove(id);
    if (result.isSuccessful()) {
      final newFavs = Set<String>.from(state.favorites);
      if (willFav) {
        newFavs.add(id);
      } else {
        newFavs.remove(id);
      }
      emit(state.copyWith(favorites: newFavs, loading: updatedLoading));
    } else {
      emit(state.copyWith(loading: updatedLoading));
    }
  }
}
