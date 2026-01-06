abstract class GroupListEvent {}

class LoadGroupsEvent extends GroupListEvent {}

class CreateGroupEvent extends GroupListEvent {
  final String name;
  final String description;

  CreateGroupEvent(this.name, this.description);
}

class JoinGroupEvent extends GroupListEvent {
  final String token;
  JoinGroupEvent({required this.token});
}
