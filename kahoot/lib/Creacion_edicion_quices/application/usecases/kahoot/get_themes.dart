import '../../../domain/entities/theme.dart';
import '../../../domain/repositories/kahoot_repository.dart';

class GetKahootThemes {
  final KahootRepository repository;
  GetKahootThemes(this.repository);

  Future<List<KahootTheme>> execute() {
    return repository.getThemes();
  }
}
