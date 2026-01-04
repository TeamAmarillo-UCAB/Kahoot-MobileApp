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

  EditGroupEvent(this.groupId, this.name, this.description);
}

class ClearInvitationLinkEvent extends GroupDetailEvent {}
