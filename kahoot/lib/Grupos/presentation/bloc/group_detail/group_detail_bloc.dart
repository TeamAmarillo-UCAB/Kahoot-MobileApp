import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/usecases/get_group_details.dart';
import '../../../application/usecases/generate_invitation.dart';
import '../../../application/usecases/remove_member.dart';
import '../../../application/usecases/delete_group.dart';
import '../../../application/usecases/edit_group.dart';
import 'group_detail_event.dart';
import 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  // Inyección de dependencias: Casos de Uso en lugar de Repositorio
  final GetGroupDetails getGroupDetails;
  final GenerateInvitation generateInvitation;
  final RemoveMember removeMember;
  final DeleteGroup deleteGroup;
  final EditGroup editGroup;

  final String currentUserId;
  String? _currentGroupId;

  GroupDetailBloc({
    required this.getGroupDetails,
    required this.generateInvitation,
    required this.removeMember,
    required this.deleteGroup,
    required this.editGroup,
    required this.currentUserId,
  }) : super(GroupDetailState.initial()) {
    // 1. Cargar detalles (Miembros, Quizzes, Ranking)
    on<LoadGroupDetailsEvent>((event, emit) async {
      _currentGroupId = event.groupId;
      emit(state.copyWith(isLoading: true, groupId: event.groupId));

      // Usamos el caso de uso "Orquestador" que creamos
      final result = await getGroupDetails(currentUserId, event.groupId);

      if (result.isSuccessful()) {
        final data = result.getValue();
        emit(
          state.copyWith(
            isLoading: false,
            members: data.members,
            quizzes: data.quizzes,
            leaderboard: data.leaderboard,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: result.getError().toString(),
          ),
        );
      }
    });

    // 2. Generar invitación (Story 8.3)
    on<GenerateInvitationEvent>((event, emit) async {
      final result = await generateInvitation(currentUserId, event.groupId);

      if (result.isSuccessful()) {
        emit(state.copyWith(invitationLink: result.getValue().invitationLink));
      } else {
        emit(state.copyWith(errorMessage: "Error al generar invitación"));
      }
    });

    // Limpiar link para no mostrar el dialog dos veces
    on<ClearInvitationLinkEvent>((event, emit) {
      emit(state.copyWith(clearInvitationLink: true));
    });

    // 3. Eliminar miembro (Story 8.4)
    on<RemoveMemberEvent>((event, emit) async {
      if (_currentGroupId == null) return;

      // Optimistic update: podrías quitarlo de la lista localmente antes,
      // pero aquí recargamos para asegurar consistencia.
      final result = await removeMember(
        currentUserId,
        _currentGroupId!,
        event.memberId,
      );

      if (result.isSuccessful()) {
        add(LoadGroupDetailsEvent(_currentGroupId!)); // Recargar lista
      } else {
        emit(state.copyWith(errorMessage: "Error al eliminar miembro"));
      }
    });

    // 4. Eliminar grupo (Story 8.5)
    on<DeleteGroupEvent>((event, emit) async {
      final result = await deleteGroup(currentUserId, event.groupId);

      if (result.isSuccessful()) {
        emit(GroupDeletedState());
      } else {
        emit(state.copyWith(errorMessage: "Error al eliminar el grupo"));
      }
    });

    // 5. Editar grupo (Story 8.5)
    on<EditGroupEvent>((event, emit) async {
      final result = await editGroup(
        currentUserId,
        event.groupId,
        event.name,
        event.description,
      );

      if (result.isSuccessful()) {
        add(LoadGroupDetailsEvent(event.groupId)); // Recargar datos nuevos
      } else {
        emit(state.copyWith(errorMessage: "Error al editar el grupo"));
      }
    });
  }
}
