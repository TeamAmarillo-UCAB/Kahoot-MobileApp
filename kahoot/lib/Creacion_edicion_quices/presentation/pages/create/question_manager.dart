import 'package:flutter/foundation.dart';

enum QuestionType { quiz, trueFalse, shortAnswer }

class QuestionData {
  final QuestionType type;
  final String question;
  final List<String> answers;
  final int time;

  QuestionData({
    required this.type,
    required this.question,
    required this.answers,
    required this.time,
  });
}

class QuestionManager extends ChangeNotifier {
  static final QuestionManager _instance = QuestionManager._internal();
  factory QuestionManager() => _instance;
  QuestionManager._internal();

  final List<QuestionData> _questions = [];
  int _selectedIndex = 0;

  List<QuestionData> get questions => List.unmodifiable(_questions);
  int get selectedIndex => _selectedIndex;

  QuestionData? getQuestion(int index) {
    if (index < 0 || index >= _questions.length) return null;
    return _questions[index];
  }

  void addQuestion(QuestionData data) {
    _questions.add(data);
    _selectedIndex = _questions.length - 1;
    notifyListeners();
  }

  void updateQuestion(int index, QuestionData data) {
    if (index < 0 || index >= _questions.length) return;
    _questions[index] = data;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    if (index < 0 || index >= _questions.length) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
