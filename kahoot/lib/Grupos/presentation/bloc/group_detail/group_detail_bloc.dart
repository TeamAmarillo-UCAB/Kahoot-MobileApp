import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/usecases/get_group_details.dart';
import '../../../application/usecases/generate_invitation.dart';
import '../../../application/usecases/remove_member.dart';
import '../../../application/usecases/delete_group.dart';
import '../../../application/usecases/edit_group.dart';
import '../../../application/usecases/get_group_leaderboard.dart';
import '../../../../Gestion_usuarios/application/usecases/get_user_by_id.dart';
import 'group_detail_event.dart';
import 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GetGroupDetails getGroupDetails;
  final GenerateInvitation generateInvitation;
  final RemoveMember removeMember;
  final DeleteGroup deleteGroup;
  final EditGroup editGroup;
  final GetGroupLeaderboard getGroupLeaderboard;
  final GetUserById getUserById;

  final String currentUserId;
  String? _currentGroupId;

  GroupDetailBloc({
    required this.getGroupDetails,
    required this.generateInvitation,
    required this.removeMember,
    required this.deleteGroup,
    required this.editGroup,
    required this.getGroupLeaderboard,
    required this.getUserById,
    required this.currentUserId,
  }) : super(GroupDetailState.initial()) {
    on<LoadGroupDetailsEvent>((event, emit) async {
      _currentGroupId = event.groupId;
      emit(state.copyWith(isLoading: true, groupId: event.groupId));

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
        final Map<String, String> namesMap = Map.from(state.memberNames);

        await Future.wait(
          data.members.map((member) async {
            if (!namesMap.containsKey(member.userId)) {
              final userResult = await getUserById(member.userId);
              if (userResult.isSuccessful() && userResult.getValue() != null) {
                print(namesMap[member.userId] = userResult.getValue()!.name);
              } else {
                namesMap[member.userId] = "Usuario desconocido";
              }
            }
          }),
        );
        emit(state.copyWith(memberNames: namesMap));
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
      final result = await removeMember(_currentGroupId!, event.memberId);

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
        add(LoadGroupDetailsEvent(event.groupId));
      } else {
        emit(state.copyWith(errorMessage: "Error al editar el grupo"));
      }
    });

    on<LoadGroupLeaderboardEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final result = await getGroupLeaderboard(currentUserId, event.groupId);

      if (result.isSuccessful()) {
        emit(state.copyWith(leaderboard: result.getValue(), isLoading: false));
      } else {
        emit(
          state.copyWith(
            errorMessage: "Error al cargar el ranking",
            isLoading: false,
          ),
        );
      }
    });
  }
}
