import '../../common/core/result.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';

class JoinGroup {
  final GroupRepository repository;

  JoinGroup(this.repository);

  Future<Result<Group>> call(String userId, String token) {
    return repository.joinGroup(userId, token);
  }
}
