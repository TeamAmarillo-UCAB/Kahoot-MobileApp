import 'question.dart';

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
  final String kahootId;
  final String authorId;
  final String title;
  final String description;
  final String image;
  final String theme;
  final KahootVisibility visibility;
  final List<Question> question;

  Kahoot({
    required this.kahootId,
    required this.authorId,
    required this.title,
    required this.description,
    required this.visibility,
    required this.question,
    this.image = '',
    this.theme = '',
  });

  factory Kahoot.fromJson(Map<String, dynamic> json) {
    return Kahoot(
      kahootId: json['kahootId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      visibility: KahootVisibilityX.fromString(json['visibility'] as String? ?? ''),
      question: Question.fromJsonList(json['questions'] as List<dynamic>? ?? const []),
    );
  }

  static List<Kahoot> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Kahoot.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}