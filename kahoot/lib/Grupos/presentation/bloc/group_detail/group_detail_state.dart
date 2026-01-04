import '../../../domain/entities/group_member.dart';
import '../../../domain/entities/assigned_quiz.dart';
import '../../../domain/entities/leaderboard_entry.dart';
import '../../../domain/entities/group_detail.dart'; // Si usas GroupDetail para la info básica

class GroupDetailState {
  final bool isLoading;
  final String? errorMessage;
  final List<GroupMember> members;
  final List<AssignedQuiz> quizzes;
  final List<LeaderboardEntry> leaderboard;
  final String? invitationLink;
  final bool isDeleted;
  final String? groupId;

  // Opcional: Para tener info del grupo (nombre, desc) en el encabezado
  final GroupDetail? groupDetails;

  const GroupDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.members = const [],
    this.quizzes = const [],
    this.leaderboard = const [],
    this.invitationLink,
    this.isDeleted = false,
    this.groupId,
    this.groupDetails,
  });

  // Estado inicial
  factory GroupDetailState.initial() => const GroupDetailState();

  GroupDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<GroupMember>? members,
    List<AssignedQuiz>? quizzes,
    List<LeaderboardEntry>? leaderboard,
    // Usamos un "truco" para permitir borrar el link pasando null explícitamente si queremos,
    // pero aquí lo manejaremos con lógica simple:
    String? invitationLink,
    bool clearInvitationLink = false, // <--- BANDERA NUEVA IMPORTANTE
    bool? isDeleted,
    String? groupId,
    GroupDetail? groupDetails,
  }) {
    return GroupDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          errorMessage, // Si pasas null, se borra el error (deseado generalmente)
      members: members ?? this.members,
      quizzes: quizzes ?? this.quizzes,
      leaderboard: leaderboard ?? this.leaderboard,
      // Lógica: Si la bandera es true, forzamos null. Si no, usamos el nuevo valor o mantenemos el viejo.
      invitationLink: clearInvitationLink
          ? null
          : (invitationLink ?? this.invitationLink),
      isDeleted: isDeleted ?? this.isDeleted,
      groupId: groupId ?? this.groupId,
      groupDetails: groupDetails ?? this.groupDetails,
    );
  }
}

// Estado especial para cuando se borra, hereda del normal
class GroupDeletedState extends GroupDetailState {
  const GroupDeletedState() : super(isDeleted: true);
}
