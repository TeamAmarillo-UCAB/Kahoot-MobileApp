import '../../../domain/entities/group.dart';

abstract class GroupListState {}

class GroupListInitial extends GroupListState {}

class GroupListLoading extends GroupListState {}

class GroupListLoaded extends GroupListState {
  final List<Group> groups;

  GroupListLoaded(this.groups);
}

class GroupListError extends GroupListState {
  final String message;

  GroupListError(this.message);
}
