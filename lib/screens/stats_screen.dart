import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/exam_state.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习统计'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ExamState>(
        builder: (context, examState, child) {
          final total = examState.totalAnswered;
          final correct = examState.totalCorrect;
          final wrong = total - correct;
          final rate = total > 0 ? correct / total * 100 : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Stats Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade600, Colors.green.shade400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.analytics, color: Colors.white, size: 30),
                          const SizedBox(width: 10),
                          const Text(
                            '总体学习情况',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('总答题', '$total', Icons.list_alt),
                          _buildStatItem('正确', '$correct', Icons.check_circle),
                          _buildStatItem('错误', '$wrong', Icons.cancel),
                          _buildStatItem('正确率', '${rate.toStringAsFixed(1)}%', Icons.percent),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Pie Chart
                if (total > 0) ...[
                  const Text(
                    '答题分布',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: correct.toDouble(),
                                  title: '',
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  color: Colors.red.shade300,
                                  value: wrong.toDouble(),
                                  title: '',
                                  radius: 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem('正确', Colors.green, correct),
                            const SizedBox(height: 15),
                            _buildLegendItem('错误', Colors.red.shade300, wrong),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                // Progress Bar
                const Text(
                  '学习进度',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('题库完成度'),
                          Text(
                            '${(examState.questions.isNotEmpty ? (examState.wrongAnswers.length / examState.questions.length * 100).clamp(0, 100) : 0).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: examState.questions.isNotEmpty
                              ? (examState.wrongAnswers.length / examState.questions.length).clamp(0.0, 1.0)
                              : 0,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildProgressItem('总题数', examState.questions.length, Colors.blue),
                          _buildProgressItem('错题数', examState.wrongAnswers.length, Colors.red),
                          _buildProgressItem('已掌握', examState.questions.length - examState.wrongAnswers.length, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Tips
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '学习建议',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _getStudyTip(rate.toDouble(), total, examState.wrongAnswers.length),
                              style: TextStyle(
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text('$label: $value'),
      ],
    );
  }

  Widget _buildProgressItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getStudyTip(double rate, int total, int wrongCount) {
    if (total == 0) {
      return '开始答题吧！坚持练习，提高正确率。';
    }
    if (rate >= 90) {
      return '太棒了！你已经掌握了大部分知识。继续保持！';
    }
    if (rate >= 70) {
      return '做得不错！建议多复习错题，进一步提升。';
    }
    if (rate >= 50) {
      return '还需要加油！建议多做练习，重点复习错题。';
    }
    return '别灰心！建议从基础题目开始，循序渐进。';
  }
}
