enum QuestionType {
  quiz_single,
  quiz_multiple,
  true_false,
  short_answer,
  slide,
}

class SlideOption {
  final String index;
  final String? text;
  final String? mediaId;

  SlideOption({required this.index, this.text, this.mediaId});

  factory SlideOption.fromJson(Map<String, dynamic> json) {
    return SlideOption(
      index: json['index'].toString(),
      text: json['text'],
      mediaId: json['mediaID'],
    );
  }
}

class Slide {
  final String slideId;
  final QuestionType type;
  final String questionText;
  final int timeLimitSeconds;
  final String? mediaId;
  final List<SlideOption> options;

  Slide({
    required this.slideId,
    required this.type,
    required this.questionText,
    required this.timeLimitSeconds,
    this.mediaId,
    required this.options,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      slideId: json['slideId'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['questionType'],
        orElse: () => QuestionType.quiz_single,
      ),
      questionText: json['questionText'] ?? '',
      timeLimitSeconds: json['timeLimitSeconds'] ?? 20,
      mediaId: json['mediaID'],
      options: (json['options'] as List? ?? [])
          .map((o) => SlideOption.fromJson(o))
          .toList(),
    );
  }
}
