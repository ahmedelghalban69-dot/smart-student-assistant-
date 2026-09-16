// Run with: flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_assistant/models/study_models.dart';

void main() {
  test('subject progress is computed from studied lessons', () {
    final s = Subject(id: '1', name: 'رياضيات', lessons: [
      Lesson(id: '1', title: 'أ'),
      Lesson(id: '2', title: 'ب', studied: true),
    ]);
    expect(s.progress, 0.5);
  });
  test('quiz attempt computes percentage', () {
    final q = QuizAttempt(id:'1', title:'اختبار', subject:'رياضيات', createdAt:DateTime.now(), correct:8, total:10);
    expect(q.score, 80);
  });
}
