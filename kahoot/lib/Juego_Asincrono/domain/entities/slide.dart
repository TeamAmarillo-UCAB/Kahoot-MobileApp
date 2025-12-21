enum QuestionType { quiz_single, quiz_multiple, true_false, short_answer , slide}

class SlideOption {
  final String index;
  final String? text;
  final String? mediaId; // <--- NUEVO CAMPO

  SlideOption({
    required this.index,
    this.text,
    this.mediaId, // <--- NUEVO EN CONSTRUCTOR
  });

  factory SlideOption.fromJson(Map<String, dynamic> json) {
    return SlideOption(
      index: json['index'].toString(),
      text: json['text'],
      mediaId: json['mediaID'], // <--- MAPEADO DEL JSON
    );
  }
}

class Slide {
  final String slideId;
  final QuestionType type;
  final String questionText;
  final String? mediaId; // <--- NUEVO CAMPO (Imagen de la pregunta)
  final List<SlideOption> options;
  final int currentNumber;
  final int totalQuestions;

  Slide({
    required this.slideId,
    required this.type,
    required this.questionText,
    this.mediaId, // <--- NUEVO EN CONSTRUCTOR
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
      mediaId: json['mediaID'], // <--- MAPEADO DEL JSON
      currentNumber: current ?? json['currentQuestionNumber'] ?? 0,
      totalQuestions: total ?? json['totalQuestions'] ?? 0,
      options: (json['options'] as List? ?? [])
          .map((o) => SlideOption.fromJson(o))
          .toList(),
    );
  }

  static QuestionType _parseType(String? type) {
    // ... (Tu lógica existente para parsear tipos)
    switch (type) {
      case 'quiz_multiple': return QuestionType.quiz_multiple;
      case 'true_false': return QuestionType.true_false;
      case 'short_answer': return QuestionType.short_answer;
      case 'slide': return QuestionType.slide;
      default: return QuestionType.quiz_single;
    }
  }
}