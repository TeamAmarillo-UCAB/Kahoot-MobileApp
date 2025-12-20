enum QuestionType { quiz_single, quiz_multiple, true_false, short_answer }

class SlideOption {
  final String index;
  final String? text;

  SlideOption({required this.index, this.text});

  factory SlideOption.fromJson(Map<String, dynamic> json) {
    return SlideOption(index: json['index'].toString(), text: json['text']);
  }
}

class Slide {
  final String slideId;
  final QuestionType type;
  final String questionText;
  final List<SlideOption> options;
  final int currentNumber;
  final int totalQuestions;

  Slide({
    required this.slideId,
    required this.type,
    required this.questionText,
    required this.options,
    required this.currentNumber,
    required this.totalQuestions,
  });

  factory Slide.fromJson(
    Map<String, dynamic> json, {
    int? current,
    int? total,
  }) {
    return Slide(
      slideId: json['slideId'] ?? '',
      type: _parseType(json['questionType']),
      questionText: json['questionText'] ?? '',
      currentNumber: current ?? json['currentQuestionNumber'] ?? 0,
      totalQuestions: total ?? json['totalQuestions'] ?? 0,
      options: (json['options'] as List? ?? [])
          .map((o) => SlideOption.fromJson(o))
          .toList(),
    );
  }

  static QuestionType _parseType(String? type) {
    switch (type) {
      case 'true_false':
        return QuestionType.true_false;
      case 'short_answer':
        return QuestionType.short_answer;
      default:
        return QuestionType.quiz_single;
    }
  }
}
