import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_models.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();
  static const _key = 'smart_student_state_v2250';
  final subjects = <Subject>[];
  final tasks = <StudyTask>[];
  final exams = <Exam>[];
  final sessions = <StudySession>[];
  final reviews = <ReviewItem>[];
  final schedule = <ScheduleItem>[];
  final quizAttempts = <QuizAttempt>[];
  final flashcards = <Flashcard>[];
  bool ready = false;
  String themeMode = 'system';
  int xp = 0;
  String lastPlannerMessage = '';

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw != null) {
      try {
        final j = Map<String, dynamic>.from(jsonDecode(raw));
        subjects.addAll(_list(j['subjects'], Subject.fromJson));
        tasks.addAll(_list(j['tasks'], StudyTask.fromJson));
        exams.addAll(_list(j['exams'], Exam.fromJson));
        sessions.addAll(_list(j['sessions'], StudySession.fromJson));
        reviews.addAll(_list(j['reviews'], ReviewItem.fromJson));
        schedule.addAll(_list(j['schedule'], ScheduleItem.fromJson));
        quizAttempts.addAll(_list(j['quizAttempts'], QuizAttempt.fromJson));
        flashcards.addAll(_list(j['flashcards'], Flashcard.fromJson));
        themeMode = j['themeMode'] ?? 'system';
        xp = j['xp'] ?? 0;
      } catch (_) {}
    }
    if (subjects.isEmpty) _seed();
    ready = true;
    notifyListeners();
  }
  List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) f) => (v as List? ?? []).map((e) => f(Map<String, dynamic>.from(e))).toList();
  void _seed() {
    subjects.addAll([
      Subject(id: 'math', name: 'الرياضيات', description: 'الجبر والهندسة والحساب', lessons: [Lesson(id: 'm1', title: 'المعادلات'), Lesson(id: 'm2', title: 'الهندسة'), Lesson(id: 'm3', title: 'النسب والتناسب')]),
      Subject(id: 'science', name: 'العلوم', description: 'مراجعة الدروس والتجارب', lessons: [Lesson(id: 's1', title: 'الطاقة'), Lesson(id: 's2', title: 'الخلايا')]),
      Subject(id: 'english', name: 'اللغة الإنجليزية', description: 'القواعد والكلمات والقراءة', lessons: [Lesson(id: 'e1', title: 'الأزمنة'), Lesson(id: 'e2', title: 'القراءة')]),
    ]);
    tasks.addAll([
      StudyTask(id: '1', title: 'حل واجب الرياضيات', subject: 'الرياضيات', priority: 1, dueDate: DateTime.now(), estimatedMinutes: 25),
      StudyTask(id: '2', title: 'مراجعة درس العلوم', subject: 'العلوم', priority: 2, estimatedMinutes: 25),
      StudyTask(id: '3', title: 'مذاكرة قواعد الإنجليزي', subject: 'اللغة الإنجليزية', priority: 2, estimatedMinutes: 30),
    ]);
    exams.add(Exam(id: 'x1', title: 'اختبار الوحدة', subject: 'الرياضيات', scope: 'المعادلات + الهندسة', questionCount: 10, type: 'وحدة'));
    reviews.addAll([ReviewItem(id: 'r1', subject: 'الرياضيات', topic: 'المعادلات', errors: 2), ReviewItem(id: 'r2', subject: 'اللغة الإنجليزية', topic: 'الأزمنة', errors: 1)]);
    flashcards.addAll([Flashcard(id: 'f1', subject: 'الرياضيات', front: 'ما المقصود بالمعادلة؟', back: 'مساواة بين تعبيرين رياضيين.')]);
  }
  int get completedTasks => tasks.where((e) => e.completed).length;
  double get taskProgress => tasks.isEmpty ? 0 : completedTasks / tasks.length;
  int get totalMinutes => sessions.fold(0, (a, b) => a + b.minutes);
  double get averageExam => exams.isEmpty ? 0 : exams.fold(0, (a, b) => a + b.score) / exams.length;
  int get completedLessons => subjects.fold(0, (a, s) => a + s.lessons.where((l) => l.studied).length);
  int get totalLessons => subjects.fold(0, (a, s) => a + s.lessons.length);
  double get learningProgress => totalLessons == 0 ? 0 : completedLessons / totalLessons;
  int get level => 1 + (xp ~/ 500);
  DateTime get _today => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode({
      'subjects': subjects.map((e) => e.toJson()).toList(), 'tasks': tasks.map((e) => e.toJson()).toList(), 'exams': exams.map((e) => e.toJson()).toList(),
      'sessions': sessions.map((e) => e.toJson()).toList(), 'reviews': reviews.map((e) => e.toJson()).toList(), 'schedule': schedule.map((e) => e.toJson()).toList(),
      'quizAttempts': quizAttempts.map((e) => e.toJson()).toList(), 'flashcards': flashcards.map((e) => e.toJson()).toList(), 'themeMode': themeMode, 'xp': xp,
    }));
  }
  void _changed([int addXp = 0]) { xp += addXp; notifyListeners(); _save(); }
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  void addSubject(String name, {String description = ''}) { subjects.add(Subject(id: _id(), name: name, description: description)); _changed(10); }
  void deleteSubject(Subject s) { subjects.remove(s); tasks.removeWhere((t) => t.subject == s.name); schedule.removeWhere((x) => x.subject == s.name); flashcards.removeWhere((x) => x.subject == s.name); _changed(); }
  void addLesson(Subject s, String title) { s.lessons.add(Lesson(id: _id(), title: title)); _changed(); }
  void toggleLesson(Subject s, Lesson l) { l.studied = !l.studied; _changed(l.studied ? 20 : 0); }
  void updateLessonContent(Lesson l, String text) { l.learnedContent = text; _changed(5); }
  void toggleTask(StudyTask t) { t.completed = !t.completed; _changed(t.completed ? 25 : 0); }
  void addTask(String title, String subject, {int priority = 2, DateTime? dueDate, int estimatedMinutes = 25}) { tasks.add(StudyTask(id: _id(), title: title, subject: subject, priority: priority, dueDate: dueDate, estimatedMinutes: estimatedMinutes)); _changed(); }
  void deleteTask(StudyTask t) { tasks.remove(t); _changed(); }
  void addExam(String title, String subject, String scope, int count, {DateTime? date, String type = 'وحدة'}) { exams.add(Exam(id: _id(), title: title, subject: subject, scope: scope, questionCount: count, date: date, type: type)); _changed(); }
  void setExamScore(Exam e, int score) { e.score = score.clamp(0, 100).toInt(); _changed(10); }
  void addSession(String subject, int minutes) { sessions.add(StudySession(id: _id(), subject: subject, minutes: minutes, startedAt: DateTime.now())); _changed(minutes >= 25 ? 50 : 10); }
  void addReview(String subject, String topic, int errors) { reviews.add(ReviewItem(id: _id(), subject: subject, topic: topic, errors: errors)); _changed(); }
  void review(ReviewItem r) { r.reviewed = true; _changed(30); }
  void addSchedule(String title, String subject, DateTime start, int minutes, {bool recurring = false}) { schedule.add(ScheduleItem(id: _id(), title: title, subject: subject, start: start, minutes: minutes, recurring: recurring, weekday: start.weekday)); schedule.sort((a, b) => a.start.compareTo(b.start)); _changed(); }
  void toggleSchedule(ScheduleItem x) { x.completed = !x.completed; _changed(x.completed ? 20 : 0); }
  void deleteSchedule(ScheduleItem x) { schedule.remove(x); _changed(); }
  void addFlashcard(String subject, String front, String back) { flashcards.add(Flashcard(id: _id(), subject: subject, front: front, back: back)); _changed(5); }
  void practiceFlashcard(Flashcard f) { f.repetitions++; _changed(5); }
  void addQuizAttempt(String title, String subject, int correct, int total) { quizAttempts.add(QuizAttempt(id: _id(), title: title, subject: subject, createdAt: DateTime.now(), correct: correct, total: total)); if (correct < total) addReview(subject, title, total - correct); else _changed(50); }
  List<ScheduleItem> scheduleFor(DateTime day) => schedule.where((x) => x.start.year == day.year && x.start.month == day.month && x.start.day == day.day).toList();
  List<StudyTask> tasksFor(DateTime day) => tasks.where((x) => x.dueDate != null && x.dueDate!.year == day.year && x.dueDate!.month == day.month && x.dueDate!.day == day.day).toList();
  List<ScheduleItem> weekFor(DateTime day) { final monday = day.subtract(Duration(days: day.weekday - 1)); return schedule.where((x) => !x.start.isBefore(DateTime(monday.year, monday.month, monday.day)) && x.start.isBefore(DateTime(monday.year, monday.month, monday.day).add(const Duration(days: 7)))).toList()..sort((a,b)=>a.start.compareTo(b.start)); }
  void generateSmartPlan(DateTime day, {int dailyMinutes = 120}) {
    schedule.removeWhere((x) => x.start.year == day.year && x.start.month == day.month && x.start.day == day.day && x.title.startsWith('خطة ذكية:'));
    final candidates = tasks.where((t) => !t.completed).toList()..sort((a,b) { final p = a.priority.compareTo(b.priority); if (p != 0) return p; return (a.dueDate ?? DateTime(2999)).compareTo(b.dueDate ?? DateTime(2999)); });
    var cursor = DateTime(day.year, day.month, day.day, 16, 0);
    var used = 0;
    for (final t in candidates) {
      if (used >= dailyMinutes) break;
      final mins = t.estimatedMinutes.clamp(15, 60).toInt();
      if (used + mins > dailyMinutes) continue;
      addSchedule('خطة ذكية: ${t.title}', t.subject, cursor, mins);
      cursor = cursor.add(Duration(minutes: mins + 10));
      used += mins;
    }
    lastPlannerMessage = used == 0 ? 'لا توجد مهام غير مكتملة تحتاج توزيعًا اليوم.' : 'تم توزيع $used دقيقة من المهام ذات الأولوية على خطة اليوم.';
    notifyListeners();
  }
  String buildStudyContext() {
    final b = StringBuffer('المواد والدروس:\n');
    for (final s in subjects) { b.writeln('- ${s.name}:'); for (final l in s.lessons) { b.writeln('  • ${l.title} | ${l.studied ? 'تمت المذاكرة' : 'لم تتم'} | ${l.learnedContent}'); } }
    b.writeln('\nالمهام غير المكتملة:'); for (final t in tasks.where((x)=>!x.completed)) b.writeln('- ${t.title} (${t.subject})');
    b.writeln('\nالاختبارات القادمة:'); for (final e in exams.where((x)=>x.date != null).take(10)) b.writeln('- ${e.title} (${e.subject}) | ${e.type} | ${e.date!.toIso8601String()}');
    b.writeln('\nالأخطاء للمراجعة:'); for (final r in reviews.where((x)=>!x.reviewed)) b.writeln('- ${r.subject}: ${r.topic} (${r.errors} أخطاء)');
    return b.toString();
  }
  void setTheme(String mode) { themeMode = mode; _changed(); }
}
