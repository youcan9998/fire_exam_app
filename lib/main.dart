import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/exam_state.dart';
import 'screens/home_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/result_screen.dart';
import 'screens/wrong_answers_screen.dart';
import 'screens/stats_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExamState()..loadQuestions(),
      child: MaterialApp(
        title: '消防设施操作员题库',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/practice': (context) => const PracticeScreen(),
          '/exam': (context) => const ExamScreen(),
          '/result': (context) => const ResultScreen(),
          '/wrong': (context) => const WrongAnswersScreen(),
          '/stats': (context) => const StatsScreen(),
        },
      ),
    );
  }
}
