import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam_state.dart';
import '../models/question.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  Timer? _timer;
  List<Map<String, dynamic>> _answers = []; // Store all answers

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Initialize answers list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examState = Provider.of<ExamState>(context, listen: false);
      _answers = List.generate(
        examState.currentQuestions.length,
        (_) => {'selected': <String>[]},
      );
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final examState = Provider.of<ExamState>(context, listen: false);
      examState.tick();
      
      if (examState.timeRemaining <= 0) {
        timer.cancel();
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitExam() {
    final examState = Provider.of<ExamState>(context, listen: false);
    examState.finishExam();
    
    int correct = 0;
    for (int i = 0; i < examState.currentQuestions.length; i++) {
      if (i < _answers.length) {
        final selected = _answers[i]['selected'] as List<String>;
        if (examState.currentQuestions[i].checkAnswer(selected)) {
          correct++;
        }
      }
    }

    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {
        'total': examState.currentQuestions.length,
        'correct': correct,
        'answers': _answers,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('模拟考试'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
        actions: [
          Consumer<ExamState>(
            builder: (context, examState, child) {
              final minutes = examState.timeRemaining ~/ 60;
              final seconds = examState.timeRemaining % 60;
              final isLow = examState.timeRemaining < 300; // < 5 min
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isLow ? Colors.red : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: isLow ? Colors.white : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExamState>(
        builder: (context, examState, child) {
          final question = examState.currentQuestion;
          if (question == null) {
            return const Center(child: Text('加载中...'));
          }

          return Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.all(15),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Text(
                      '第 ${examState.currentIndex + 1} / ${examState.currentQuestions.length} 题',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: (examState.currentIndex + 1) / examState.currentQuestions.length,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: question.isMultiple ? Colors.orange : Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        question.isMultiple ? '多选' : '单选',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                        child: Text(
                          question.question,
                          style: const TextStyle(fontSize: 18, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Options
                      ...['A', 'B', 'C', 'D'].map((option) {
                        if (question.options[option] == null) return const SizedBox.shrink();
                        return _buildOptionCard(
                          context,
                          examState,
                          option,
                          question.options[option]!,
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (examState.currentIndex > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _saveCurrentAnswer(examState);
                            examState.previousQuestion();
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('上一题'),
                        ),
                      ),
                    if (examState.currentIndex > 0) const SizedBox(width: 15),
                    if (examState.currentIndex < examState.currentQuestions.length - 1)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _saveCurrentAnswer(examState);
                            examState.nextQuestion();
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('下一题'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (examState.currentIndex == examState.currentQuestions.length - 1)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showSubmitDialog(),
                          icon: const Icon(Icons.check),
                          label: const Text('交卷'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveCurrentAnswer(ExamState examState) {
    if (examState.currentIndex < _answers.length) {
      _answers[examState.currentIndex] = {
        'selected': List<String>.from(examState.selectedAnswers),
      };
    }
  }

  Widget _buildOptionCard(
    BuildContext context,
    ExamState examState,
    String option,
    String text,
  ) {
    final isSelected = examState.selectedAnswers.contains(option);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => examState.selectAnswer(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.orange : Colors.grey.shade200,
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.orange.shade700 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('退出考试将不会保存当前进度，确定要退出吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
  }

  void _showSubmitDialog() {
    int unanswered = 0;
    for (var answer in _answers) {
      if ((answer['selected'] as List).isEmpty) {
        unanswered++;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认交卷'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, size: 50, color: Colors.orange),
            const SizedBox(height: 15),
            if (unanswered > 0)
              Text(
                '还有 $unanswered 题未作答',
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            const Text('确定要交卷吗？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续答题'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('确认交卷'),
          ),
        ],
      ),
    );
  }
}
