import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'question.dart';

class ExamState extends ChangeNotifier {
  List<Question> questions = [];
  List<Question> currentQuestions = [];
  int currentIndex = 0;
  List<String> selectedAnswers = [];
  List<Question> wrongAnswers = [];
  int totalAnswered = 0;
  int totalCorrect = 0;
  bool isLoading = true;
  int examDuration = 60;
  bool isExamMode = false;
  int timeRemaining = 0;

  double get correctRate {
    if (totalAnswered == 0) return 0;
    return totalCorrect / totalAnswered;
  }

  Question? get currentQuestion {
    if (currentQuestions.isEmpty) return null;
    if (currentIndex < 0) return null;
    if (currentIndex >= currentQuestions.length) return null;
    return currentQuestions[currentIndex];
  }

  Future<void> loadQuestions() async {
    isLoading = true;
    notifyListeners();

    try {
      final jsonString = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      questions = jsonList.asMap().entries.map((entry) {
        return Question.fromJson(entry.value, entry.key);
      }).toList();

      isLoading = false;
      await _loadStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading questions: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      totalAnswered = prefs.getInt('totalAnswered') ?? 0;
      totalCorrect = prefs.getInt('totalCorrect') ?? 0;

      final wrongJson = prefs.getString('wrongAnswers');
      if (wrongJson != null) {
        final List<dynamic> wrongList = jsonDecode(wrongJson);
        wrongAnswers = wrongList.asMap().entries.map((entry) {
          return Question.fromJson(entry.value, entry.key);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('totalAnswered', totalAnswered);
      await prefs.setInt('totalCorrect', totalCorrect);

      final wrongJson = jsonEncode(wrongAnswers.map((q) => q.toJson()).toList());
      await prefs.setString('wrongAnswers', wrongJson);
    } catch (e) {
      debugPrint('Error saving stats: $e');
    }
  }

  void startPractice() {
    isExamMode = false;
    currentQuestions = List.from(questions);
    currentQuestions.shuffle();
    currentIndex = 0;
    selectedAnswers = [];
    notifyListeners();
  }

  void startExam({int questionCount = 50, int durationMinutes = 60}) {
    isExamMode = true;
    examDuration = durationMinutes;
    timeRemaining = durationMinutes * 60;

    currentQuestions = List.from(questions);
    currentQuestions.shuffle();
    if (currentQuestions.length > questionCount) {
      currentQuestions = currentQuestions.sublist(0, questionCount);
    }

    currentIndex = 0;
    selectedAnswers = [];
    notifyListeners();
  }

  void selectAnswer(String option) {
    final q = currentQuestion;
    if (q == null) return;

    if (q.isMultiple) {
      if (selectedAnswers.contains(option)) {
        selectedAnswers.remove(option);
      } else {
        selectedAnswers.add(option);
      }
    } else {
      selectedAnswers = [option];
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < currentQuestions.length - 1) {
      currentIndex++;
      selectedAnswers = [];
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      currentIndex--;
      selectedAnswers = [];
      notifyListeners();
    }
  }

  Future<void> submitAnswer() async {
    final q = currentQuestion;
    if (q == null || selectedAnswers.isEmpty) return;

    final isCorrect = q.checkAnswer(selectedAnswers);

    totalAnswered++;
    if (isCorrect) {
      totalCorrect++;
    } else {
      final exists = wrongAnswers.any((w) => w.id == q.id);
      if (!exists) {
        wrongAnswers.add(q);
      }
    }

    await _saveStats();
    notifyListeners();
  }

  void tick() {
    if (isExamMode && timeRemaining > 0) {
      timeRemaining--;
      notifyListeners();
    }
  }

  Future<void> finishExam() async {
    isExamMode = false;
    await _saveStats();
    notifyListeners();
  }

  void clearWrongAnswers() {
    wrongAnswers = [];
    _saveStats();
    notifyListeners();
  }

  void startWrongAnswersReview() {
    isExamMode = false;
    currentQuestions = List.from(wrongAnswers);
    currentIndex = 0;
    selectedAnswers = [];
    notifyListeners();
  }

  void resetSession() {
    currentIndex = 0;
    selectedAnswers = [];
    notifyListeners();
  }
}
