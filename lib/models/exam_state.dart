import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'question.dart';

class ExamState extends ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _currentQuestions = [];
  int _currentIndex = 0;
  List<String> _selectedAnswers = [];
  List<Question> _wrongAnswers = [];
  int _totalAnswered = 0;
  int _totalCorrect = 0;
  bool _isLoading = true;
  int _examDuration = 60; // minutes
  bool _isExamMode = false;
  int _timeRemaining = 0; // seconds

  // Getters
  List<Question> get questions => _questions;
  List<Question> get currentQuestions => _currentQuestions;
  int get currentIndex => _currentIndex;
  List<String> get selectedAnswers => _selectedAnswers;
  List<Question> get wrongAnswers => _wrongAnswers;
  int get totalAnswered => _totalAnswered;
  int get totalCorrect => _totalCorrect;
  bool get isLoading => _isLoading;
  int get examDuration => _examDuration;
  bool get isExamMode => _isExamMode;
  int get timeRemaining => _timeRemaining;

  Question? get currentQuestion =>
      _currentIndex < _currentQuestions.length ? _currentQuestions[_currentIndex] : null;

  double get correctRate => _totalAnswered > 0 ? _totalCorrect / _totalAnswered : 0;

  Future<void> loadQuestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load from JSON file in assets
      final jsonString = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      _questions = jsonList.asMap().entries.map((entry) {
        return Question.fromJson(entry.value, entry.key);
      }).toList();
      
      _isLoading = false;
      await _loadStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading questions: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalAnswered = prefs.getInt('totalAnswered') ?? 0;
      _totalCorrect = prefs.getInt('totalCorrect') ?? 0;

      // Load wrong answers
      final wrongJson = prefs.getString('wrongAnswers');
      if (wrongJson != null) {
        final List<dynamic> wrongList = jsonDecode(wrongJson);
        _wrongAnswers = wrongList.asMap().entries.map((entry) {
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
      await prefs.setInt('totalAnswered', _totalAnswered);
      await prefs.setInt('totalCorrect', _totalCorrect);

      // Save wrong answers
      final wrongJson = jsonEncode(_wrongAnswers.map((q) => q.toJson()).toList());
      await prefs.setString('wrongAnswers', wrongJson);
    } catch (e) {
      debugPrint('Error saving stats: $e');
    }
  }

  void startPractice() {
    _isExamMode = false;
    _currentQuestions = List.from(_questions);
    _currentQuestions.shuffle();
    _currentIndex = 0;
    _selectedAnswers = [];
    notifyListeners();
  }

  void startExam({int questionCount = 50, int durationMinutes = 60}) {
    _isExamMode = true;
    _examDuration = durationMinutes;
    _timeRemaining = durationMinutes * 60;

    // Random select questions
    _currentQuestions = List.from(_questions);
    _currentQuestions.shuffle();
    if (_currentQuestions.length > questionCount) {
      _currentQuestions = _currentQuestions.sublist(0, questionCount);
    }

    _currentIndex = 0;
    _selectedAnswers = [];
    notifyListeners();
  }

  void selectAnswer(String option) {
    if (_currentQuestion == null) return;

    if (_currentQuestion!.isMultiple) {
      // 多选题：切换选择状态
      if (_selectedAnswers.contains(option)) {
        _selectedAnswers.remove(option);
      } else {
        _selectedAnswers.add(option);
      }
    } else {
      // 单选题：直接选中
      _selectedAnswers = [option];
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _currentQuestions.length - 1) {
      _currentIndex++;
      _selectedAnswers = [];
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _selectedAnswers = [];
      notifyListeners();
    }
  }

  Future<void> submitAnswer() async {
    if (_currentQuestion == null || _selectedAnswers.isEmpty) return;

    final isCorrect = _currentQuestion!.checkAnswer(_selectedAnswers);

    // Update stats
    _totalAnswered++;
    if (isCorrect) {
      _totalCorrect++;
    } else {
      // Add to wrong answers if not already there
      final exists = _wrongAnswers.any((q) => q.id == _currentQuestion!.id);
      if (!exists) {
        _wrongAnswers.add(_currentQuestion!);
      }
    }

    await _saveStats();
    notifyListeners();
  }

  void tick() {
    if (_isExamMode && _timeRemaining > 0) {
      _timeRemaining--;
      notifyListeners();
    }
  }

  Future<void> finishExam() async {
    _isExamMode = false;
    await _saveStats();
    notifyListeners();
  }

  void clearWrongAnswers() {
    _wrongAnswers = [];
    _saveStats();
    notifyListeners();
  }

  // Reset current session
  void resetSession() {
    _currentIndex = 0;
    _selectedAnswers = [];
    notifyListeners();
  }
}
