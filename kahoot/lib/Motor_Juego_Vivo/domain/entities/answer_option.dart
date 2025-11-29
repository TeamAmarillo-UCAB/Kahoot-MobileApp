class AnswerOption {
  final int index;
  final String? text;
  final String? mediaUrl;

  AnswerOption({required this.index, this.text, this.mediaUrl});

  factory AnswerOption.fromJson(Map<String, dynamic> json) => AnswerOption(
    index: json['index'] is int ? json['index'] : int.parse(json['index'].toString()),
    text: json['text'] as String?,
    mediaUrl: json['mediaUrl'] as String?,
  );
}
