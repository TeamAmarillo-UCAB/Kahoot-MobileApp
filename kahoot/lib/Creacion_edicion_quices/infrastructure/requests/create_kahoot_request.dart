Map<String, dynamic> buildCreateKahootRequest({
  required String authorId,
  required String title,
  required String description,
  String? coverImageId,
  required String visibility, // 'public' | 'private'
  String? themeId,
  required String status, // 'draft' | 'finished' etc
  required List<Map<String, dynamic>> questions, // each question is a map with keys below
}) {
  return {
    'authorId': authorId,
    'title': title,
    'description': description,
    'coverImageId': coverImageId,
    'visibility': visibility,
    'themeId': themeId,
    'status': status,
    'questions': questions.map((q) => {
      'questionText': q['questionText'] ?? '',
      'mediaId': q['mediaId'],
      'questionType': q['questionType'] ?? 'quiz',
      'timeLimit': q['timeLimit'] ?? 0,
      'points': q['points'] ?? 0,
      'answers': (q['answers'] as List<dynamic>? ?? []).map((a) => {
        'answerText': a['answerText'] ?? a['text'] ?? '',
        'mediaId': a['mediaId'],
        'isCorrect': a['isCorrect'] ?? false,
      }).toList(),
    }).toList(),
  };
}

// Example helper to build a question map:
Map<String, dynamic> buildQuestion({
  required String questionText,
  String? mediaId,
  required String questionType, // e.g. 'quiz' or 'true_false'
  required int timeLimit,
  required int points,
  required List<Map<String, dynamic>> answers,
}) => {
      'questionText': questionText,
      'mediaId': mediaId,
      'questionType': questionType,
      'timeLimit': timeLimit,
      'points': points,
      'answers': answers,
    };

// Example helper to build an answer map:
Map<String, dynamic> buildAnswer({
  required String answerText,
  String? mediaId,
  required bool isCorrect,
}) => {
      'answerText': answerText,
      'mediaId': mediaId,
      'isCorrect': isCorrect,
    };
