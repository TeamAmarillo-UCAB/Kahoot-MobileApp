class LiveSlide {
  final String id;
  final int questionIndex;
  final int totalQuestions;
  final String slideType;
  final int timeLimit;
  final String questionText;
  final String? imageUrl;
  final int pointsValue;
  final List<LiveOption> options;

  LiveSlide({
    required this.id,
    required this.questionIndex,
    required this.totalQuestions,
    required this.slideType,
    required this.timeLimit,
    required this.questionText,
    required this.pointsValue,
    required this.options,
    this.imageUrl,
  });

  factory LiveSlide.fromJson(Map<String, dynamic> json) {
    return LiveSlide(
      id: json['id']?.toString() ?? '',
      questionIndex: json['position'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      slideType: json['slideType'] ?? '',
      timeLimit: json['timeLimitSeconds'] ?? 0,
      questionText: json['questionText'] ?? '',
      imageUrl: json['slideImageURL'],
      pointsValue: json['pointsValue'] ?? 0,
      options: (json['options'] as List? ?? [])
          .map((o) => LiveOption.fromJson(o))
          .toList(),
    );
  }
}

class LiveOption {
  final String index;
  final String? text;
  final String? mediaUrl;

  LiveOption({required this.index, this.text, this.mediaUrl});

  factory LiveOption.fromJson(Map<String, dynamic> json) {
    return LiveOption(
      index: json['index'].toString(),
      text: json['text'],
      mediaUrl: json['mediaURL'],
    );
  }
}
