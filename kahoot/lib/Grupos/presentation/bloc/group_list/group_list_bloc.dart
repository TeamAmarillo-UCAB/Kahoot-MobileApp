import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/usecases/get_user_groups.dart';
import '../../../application/usecases/create_group.dart';
import '../../../application/usecases/join_group.dart';
import 'group_list_event.dart';
import 'group_list_state.dart';

class GroupListBloc extends Bloc<GroupListEvent, GroupListState> {
  // Inyección de Casos de Uso
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
    // Cargar Mis Grupos (Story 8.1)
    on<LoadGroupsEvent>((event, emit) async {
      emit(GroupListLoading());
      final result = await getUserGroups(currentUserId);

      if (result.isSuccessful()) {
        emit(GroupListLoaded(result.getValue()));
      } else {
        emit(GroupListError(result.getError().toString()));
      }
    });

    // Crear Grupo (Story 8.2)
    on<CreateGroupEvent>((event, emit) async {
      emit(GroupListLoading());
      final result = await createGroup(
        currentUserId,
        event.name,
        event.description,
      );

      if (result.isSuccessful()) {
        // Si se crea con éxito, recargamos la lista completa
        add(LoadGroupsEvent());
      } else {
        emit(GroupListError("Error al crear el grupo: ${result.getError()}"));
        // Volvemos a cargar los grupos antiguos para no dejar la pantalla vacía
        add(LoadGroupsEvent());
      }
    });

    // Unirse a Grupo (Story 8.3)
    on<JoinGroupEvent>((event, emit) async {
      emit(GroupListLoading());
      final result = await joinGroup(currentUserId, event.token);

      if (result.isSuccessful()) {
        add(LoadGroupsEvent());
      } else {
        emit(GroupListError("Error al unirse o código inválido"));
        add(LoadGroupsEvent());
      }
    });
  }
}
