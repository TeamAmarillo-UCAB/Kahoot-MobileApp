class QuestionSlideOption {
  final int index;      // answerId a enviar en player_submit_answer
  final String? text;
  final String? imageUrl;

  const QuestionSlideOption({
    required this.index,
    this.text,
    this.imageUrl,
  });

  factory QuestionSlideOption.fromJson(Map<String, dynamic> json, int index) {
    return QuestionSlideOption(
      index: index,
      text: json["text"],
      imageUrl: json["image"],
    );
  }
}


enum QuestionType { multipleChoice, trueFalse }

extension QuestionTypeX on QuestionType {
  String toShortString() => toString().split('.').last;

  static QuestionType fromString(String value) {
    final normalized = value.trim().toUpperCase();

    switch (normalized) {
      case "MULTIPLE_CHOICE":
        return QuestionType.multipleChoice;
      case "TRUE_FALSE":
        return QuestionType.trueFalse;
      default:
        return QuestionType.multipleChoice;
    }
  }
}

// ───────────────────────────────────────────────
// ENTIDAD PRINCIPAL DEL SLIDE DE PREGUNTA
// ───────────────────────────────────────────────

class QuestionSlide {
  final String slideId;
  final int questionIndex;
  final String questionText;
  final String? mediaUrl;
  final int timeLimitSeconds;
  final QuestionType type;
  final List<QuestionSlideOption> options;

  const QuestionSlide({
    required this.slideId,
    required this.questionIndex,
    required this.questionText,
    this.mediaUrl,
    required this.timeLimitSeconds,
    required this.type,
    required this.options,
  });

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  int get optionsCount => options.length;

  factory QuestionSlide.fromJson(Map<String, dynamic> json) {
    final optList = json["options"] as List<dynamic>? ?? [];

    return QuestionSlide(
      slideId: json["slideId"] ?? "",
      questionIndex: json["questionIndex"] ?? 0,
      questionText: json["questionText"] ?? "",
      mediaUrl: json["mediaUrl"],
      timeLimitSeconds: json["timeLimitSeconds"] ?? 0,
      type: QuestionTypeX.fromString(json["type"] ?? "MULTIPLE_CHOICE"),
      options: List.generate(
        optList.length,
        (i) => QuestionSlideOption.fromJson(optList[i], i),
      ),
    );
  }
}
