import '../../common/core/result.dart';
import '../../domain/entities/group_invitation.dart';
import '../../domain/repositories/group_repository.dart';

class GenerateInvitation {
  final GroupRepository repository;

  GenerateInvitation(this.repository);

  Future<Result<GroupInvitation>> call(String userId, String groupId) {
    return repository.generateInvitation(userId, groupId);
  }
}
