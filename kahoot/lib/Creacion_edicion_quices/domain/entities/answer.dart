class Answer {
  final String image;
  final bool isCorrect;
  final String text;
  final String questionId;

  Answer({
    required this.image,
    required this.isCorrect,
    required this.text,
    required this.questionId,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      image: json['image'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      questionId: json['questionId'] as String? ?? '',
    );
  }

  static List<Answer> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Answer.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}