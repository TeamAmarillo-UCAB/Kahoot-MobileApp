import '../../common/core/result.dart';
import '../../domain/repositories/group_repository.dart';

class TransferAdmin {
  final GroupRepository repository;

  TransferAdmin(this.repository);

  Future<Result<void>> call(String userId, String groupId, String newAdminId) {
    return repository.transferAdmin(userId, groupId, newAdminId);
  }
}
