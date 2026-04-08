import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam_state.dart';
import '../models/question.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习模式'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
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
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade100),
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

                      if (examState.selectedAnswers.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildAnswerFeedback(examState, question),
                      ],
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
                          onPressed: () => examState.previousQuestion(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('上一题'),
                        ),
                      ),
                    if (examState.currentIndex > 0) const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: examState.selectedAnswers.isEmpty
                            ? null
                            : () => _handleNext(context, examState),
                        icon: Icon(
                          examState.currentIndex == examState.currentQuestions.length - 1
                              ? Icons.check
                              : Icons.arrow_forward,
                        ),
                        label: Text(
                          examState.currentIndex == examState.currentQuestions.length - 1
                              ? '完成练习'
                              : '下一题',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
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
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => examState.selectAnswer(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
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
                    color: isSelected ? Colors.blue : Colors.grey.shade200,
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
                      color: isSelected ? Colors.blue.shade700 : Colors.black87,
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

  Widget _buildAnswerFeedback(ExamState examState, Question question) {
    final isCorrect = question.checkAnswer(examState.selectedAnswers);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isCorrect ? Colors.green : Colors.red),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? '回答正确！' : '回答错误',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                if (!isCorrect)
                  Text(
                    '正确答案: ${question.answer}',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext(BuildContext context, ExamState examState) async {
    await examState.submitAnswer();

    if (examState.currentIndex < examState.currentQuestions.length - 1) {
      examState.nextQuestion();
    } else {
      // Show completion dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.orange),
                SizedBox(width: 10),
                Text('练习完成'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 60,
                  color: Colors.green,
                ),
                const SizedBox(height: 15),
                const Text('恭喜你完成了本次练习！'),
                const SizedBox(height: 10),
                Text(
                  '答题数: ${examState.currentQuestions.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to home
                },
                child: const Text('返回首页'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  examState.startPractice();
                },
                child: const Text('再来一次'),
              ),
            ],
          ),
        );
      }
    }
  }
}
