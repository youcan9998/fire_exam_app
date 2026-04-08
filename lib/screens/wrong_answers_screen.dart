import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam_state.dart';
import '../models/question.dart';

class WrongAnswersScreen extends StatelessWidget {
  const WrongAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题本'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<ExamState>(
            builder: (context, examState, child) {
              if (examState.wrongAnswers.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearDialog(context, examState),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExamState>(
        builder: (context, examState, child) {
          if (examState.wrongAnswers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '暂无错题',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '继续保持，练习更多题目来巩固知识',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('返回首页'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(
                      '共 ${examState.wrongAnswers.length} 道错题',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _practiceWrongAnswers(context, examState),
                      icon: const Icon(Icons.refresh),
                      label: const Text('重练错题'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: examState.wrongAnswers.length,
                  itemBuilder: (context, index) {
                    final question = examState.wrongAnswers[index];
                    return _buildQuestionCard(context, question, index + 1);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, Question question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        childrenPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: Text(
            '$index',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          question.question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: question.isMultiple ? Colors.orange : Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.isMultiple ? '多选' : '单选',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '正确答案: ${question.answer}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        children: [
          ...['A', 'B', 'C', 'D'].map((option) {
            if (question.options[option] == null) return const SizedBox.shrink();
            final isCorrect = question.answer.contains(option);
            final letter = option.substring(0, 1);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect ? Colors.green : Colors.grey.shade300,
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      question.options[option]!,
                      style: TextStyle(
                        color: isCorrect ? Colors.green.shade700 : Colors.black87,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check, color: Colors.green),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, ExamState examState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空错题本'),
        content: const Text('确定要清空所有错题记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              examState.clearWrongAnswers();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }

  void _practiceWrongAnswers(BuildContext context, ExamState examState) {
    if (examState.wrongAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无错题')),
      );
      return;
    }

    examState.currentQuestions = List.from(examState.wrongAnswers);
    examState.currentIndex = 0;
    examState.selectedAnswers = [];
    examState.isExamMode = false;
    Navigator.pushNamed(context, '/practice');
  }
}
