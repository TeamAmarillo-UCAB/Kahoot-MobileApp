import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/add_kahoot_to_favorite_usecase.dart';
import '../../application/remove_kahoot_from_favorite_usecase.dart';
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
  final AddKahootToFavoriteUseCase addFavorite;
  final RemoveKahootFromFavoriteUseCase removeFavorite;
  FavoritesCubit({required this.addFavorite, required this.removeFavorite}) : super(const FavoritesState());

  bool isFavorite(String id) => state.favorites.contains(id);
  bool isBusy(String id) => state.loading.contains(id);

  Future<void> toggle(String id) async {
    if (state.loading.contains(id)) return;
    final newLoading = Set<String>.from(state.loading)..add(id);
    emit(state.copyWith(loading: newLoading));

    final bool willFav = !state.favorites.contains(id);
    Result<void> result;
    if (willFav) {
      result = await addFavorite.call(id);
    } else {
      result = await removeFavorite.call(id);
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
