import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/usecases/get_user_groups.dart';
import '../../../application/usecases/create_group.dart';
import '../../../application/usecases/join_group.dart';
import 'group_list_event.dart';
import 'group_list_state.dart';

class GroupListBloc extends Bloc<GroupListEvent, GroupListState> {
  final GetUserGroups getUserGroups;
  final CreateGroup createGroup;
  final JoinGroup joinGroup;
  final String currentUserId;

  GroupListBloc({
    required this.getUserGroups,
    required this.createGroup,
    required this.joinGroup,
    required this.currentUserId,
  }) : super(GroupListInitial()) {
    // 1. Manejador de Carga
    on<LoadGroupsEvent>((event, emit) async {
      await _loadGroups(emit);
    });

    // 2. Manejador de Creación
    on<CreateGroupEvent>((event, emit) async {
      emit(GroupListLoading());
      final result = await createGroup(
        currentUserId,
        event.name,
        event.description,
      );

      if (result.isSuccessful()) {
        // CORRECCIÓN: En lugar de add(LoadGroupsEvent()), llamamos a la lógica directa
        // Esto evita el error de "Bloc cerrado" porque usamos el 'emit' actual.
        await _loadGroups(emit);
      } else {
        emit(GroupListError("Error al crear: ${result.getError()}"));
        // Si falló, recargamos la lista que teníamos antes
        await _loadGroups(emit);
      }
    });

    // 3. Manejador de Unirse
    on<JoinGroupEvent>((event, emit) async {
      emit(GroupListLoading());
      final result = await joinGroup(currentUserId, event.token);

      if (result.isSuccessful()) {
        await _loadGroups(emit);
      } else {
        emit(GroupListError("Error al unirse o código inválido"));
        await _loadGroups(emit);
      }
    });
  }

  // --- MÉTODO PRIVADO REUTILIZABLE ---
  // Esta función hace el trabajo sucio y es segura de llamar desde cualquier evento
  Future<void> _loadGroups(Emitter<GroupListState> emit) async {
    // Nota: No emitimos 'Loading' aquí dentro para no parpadear
    // si ya venimos de una acción de carga.

    final result = await getUserGroups(currentUserId);

    if (result.isSuccessful()) {
      emit(GroupListLoaded(result.getValue()));
    } else {
      emit(GroupListError(result.getError().toString()));
    }
  }
}
