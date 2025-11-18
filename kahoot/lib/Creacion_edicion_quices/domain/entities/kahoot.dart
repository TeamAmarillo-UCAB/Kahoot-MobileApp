import 'slide.dart';
enum KahootStatus { draft, finished }

extension KahootStatusX on KahootStatus {
  String toShortString() => toString().split('.').last;
  static KahootStatus fromString(String value) {
    return KahootStatus.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => KahootStatus.draft,
    );
  }
}

enum KahootVisibility { private, public }

extension KahootVisibilityX on KahootVisibility {
  String toShortString() => toString().split('.').last;
  static KahootVisibility fromString(String value) {
    final normalized = value.replaceAll(' ', '_').toLowerCase();
    return KahootVisibility.values.firstWhere(
      (e) => e.toShortString().toLowerCase() == normalized,
      orElse: () => KahootVisibility.private,
    );
  }
}

 class Kahoot {
  final String id;
  final String title;
  final String description;
  final String image;
  final String theme;
  final DateTime creationDate;
  final KahootStatus status;
  final KahootVisibility visibility;
  final List<Slide> questions;

  Kahoot({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.status,
    required this.visibility,
    this.image = '',
    this.theme = '',
    DateTime? creationDate,
  }) : creationDate = creationDate ?? DateTime.now();
}