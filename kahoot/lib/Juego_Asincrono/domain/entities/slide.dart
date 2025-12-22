class Slide {
  final String slideId;
  final String question;
  final int timeLimit;
  final List<Option> options;

  Slide({
    required this.slideId,
    required this.question,
    required this.timeLimit,
    required this.options,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      slideId: json['slideId'] ?? '',
      question: json['questionText'] ?? '',
      timeLimit: json['timeLimitSeconds'] ?? 30,
      options: (json['options'] as List? ?? [])
          .map((o) => Option.fromJson(o))
          .toList(),
    );
  }
}

class Option {
  final int index;
  final String text;

  Option({required this.index, required this.text});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      index: int.parse(json['index'].toString()),
      text: json['text'] ?? '',
    );
  }
}
