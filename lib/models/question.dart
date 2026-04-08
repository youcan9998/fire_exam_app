class Question {
  final String id;
  final String question;
  final Map<String, String> options; // A, B, C, D
  final String answer; // Single: "A", Multiple: "ABC"
  final String type; // "single" or "multiple"

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.type,
  });

  bool get isMultiple => type == 'multiple';

  bool checkAnswer(List<String> selected) {
    if (isMultiple) {
      // 多选题：检查是否完全匹配
      final correctSet = answer.split('').toSet();
      final selectedSet = selected.toSet();
      return correctSet.containsAll(selectedSet) && selectedSet.containsAll(correctSet);
    } else {
      // 单选题
      return selected.length == 1 && answer == selected[0];
    }
  }

  bool checkSingleAnswer(String selected) {
    return !isMultiple && selected == answer;
  }

  bool checkMultipleAnswer(List<String> selected) {
    if (!isMultiple) return false;
    final correctSet = answer.split('').toSet();
    final selectedSet = selected.toSet();
    return correctSet.containsAll(selectedSet) && selectedSet.containsAll(correctSet);
  }

  factory Question.fromJson(Map<String, dynamic> json, int index) {
    return Question(
      id: 'q_${index + 1}',
      question: json['question'] ?? '',
      options: Map<String, String>.from(json['options'] ?? {}),
      answer: json['answer'] ?? '',
      type: json['type'] ?? 'single',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answer': answer,
      'type': type,
    };
  }
}
