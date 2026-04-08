import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exam_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消防设施操作员题库'),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ExamState>(
        builder: (context, examState, child) {
          if (examState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.red.shade50, Colors.white],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '消防设施操作员',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '共 ${examState.questions.length} 道题目',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade100,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Menu Buttons
                    Expanded(
                      child: Column(
                        children: [
                          _buildMenuButton(
                            context,
                            icon: Icons.edit_note,
                            title: '练习模式',
                            subtitle: '顺序刷题，即时反馈',
                            color: Colors.blue,
                            onTap: () {
                              examState.startPractice();
                              Navigator.pushNamed(context, '/practice');
                            },
                          ),

                          const SizedBox(height: 15),

                          _buildMenuButton(
                            context,
                            icon: Icons.timer,
                            title: '模拟考试',
                            subtitle: '限时作答，自动评分',
                            color: Colors.orange,
                            onTap: () {
                              _showExamConfigDialog(context, examState);
                            },
                          ),

                          const SizedBox(height: 15),

                          _buildMenuButton(
                            context,
                            icon: Icons.error_outline,
                            title: '错题本',
                            subtitle: '查看并练习错题',
                            color: Colors.red,
                            badge: examState.wrongAnswers.length > 0
                                ? '${examState.wrongAnswers.length}'
                                : null,
                            onTap: () {
                              Navigator.pushNamed(context, '/wrong');
                            },
                          ),

                          const SizedBox(height: 15),

                          _buildMenuButton(
                            context,
                            icon: Icons.bar_chart,
                            title: '学习统计',
                            subtitle: '查看答题数据',
                            color: Colors.green,
                            onTap: () {
                              Navigator.pushNamed(context, '/stats');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showExamConfigDialog(BuildContext context, ExamState examState) {
    int questionCount = 50;
    int duration = 60;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('模拟考试设置'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('题目数量: $questionCount'),
                  Slider(
                    value: questionCount.toDouble(),
                    min: 20,
                    max: examState.questions.length.toDouble(),
                    divisions: (examState.questions.length - 20) ~/ 5,
                    label: '$questionCount',
                    onChanged: (value) {
                      setState(() {
                        questionCount = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('考试时长: $duration 分钟'),
                  Slider(
                    value: duration.toDouble(),
                    min: 30,
                    max: 120,
                    divisions: 9,
                    label: '$duration',
                    onChanged: (value) {
                      setState(() {
                        duration = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    examState.startExam(
                      questionCount: questionCount,
                      durationMinutes: duration,
                    );
                    Navigator.pushNamed(context, '/exam');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('开始考试'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
