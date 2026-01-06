abstract class GroupDetailEvent {}

class LoadGroupDetailsEvent extends GroupDetailEvent {
  final String groupId;
  LoadGroupDetailsEvent(this.groupId);
}

class GenerateInvitationEvent extends GroupDetailEvent {
  final String groupId;
  GenerateInvitationEvent(this.groupId);
}

class RemoveMemberEvent extends GroupDetailEvent {
  final String memberId;
  RemoveMemberEvent({required this.memberId});
}

class DeleteGroupEvent extends GroupDetailEvent {
  final String groupId;
  DeleteGroupEvent(this.groupId);
}

class EditGroupEvent extends GroupDetailEvent {
  final String groupId;
  final String name;
  final String description;

  EditGroupEvent({
    required this.groupId,
    required this.name,
    required this.description,
  });

  List<Object> get props => [groupId, name, description];
}

class ClearInvitationLinkEvent extends GroupDetailEvent {}

class LoadGroupLeaderboardEvent extends GroupDetailEvent {
  final String groupId;
  LoadGroupLeaderboardEvent({required this.groupId});
}
