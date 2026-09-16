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
      } catch (_) {
        // Ignore invalid saved state and use seed data below.
      }
    }

    if (subjects.isEmpty) {
      _seed();
    }

    ready = true;
    notifyListeners();
  }

  List<T> _list<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = value as List? ?? [];
    return list
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void _seed() {
    subjects.addAll([
      Subject(
        id: 'math',
        name: 'الرياضيات',
        description: 'الجبر والهندسة والحساب',
        lessons: [
          Lesson(id: 'm1', title: 'المعادلات'),
          Lesson(id: 'm2', title: 'الهندسة'),
          Lesson(id: 'm3', title: 'النسب والتناسب'),
        ],
      ),
      Subject(
        id: 'science',
        name: 'العلوم',
        description: 'مراجعة الدروس والتجارب',
        lessons: [
          Lesson(id: 's1', title: 'الطاقة'),
          Lesson(id: 's2', title: 'الخلايا'),
        ],
      ),
      Subject(
        id: 'english',
        name: 'اللغة الإنجليزية',
        description: 'القواعد والكلمات والقراءة',
        lessons: [
          Lesson(id: 'e1', title: 'الأزمنة'),
          Lesson(id: 'e2', title: 'القراءة'),
        ],
      ),
    ]);

    tasks.addAll([
      StudyTask(
        id: '1',
        title: 'حل واجب الرياضيات',
        subject: 'الرياضيات',
        priority: 1,
        dueDate: DateTime.now(),
        estimatedMinutes: 25,
      ),
      StudyTask(
        id: '2',
        title: 'مراجعة درس العلوم',
        subject: 'العلوم',
        priority: 2,
        estimatedMinutes: 25,
      ),
      StudyTask(
        id: '3',
        title: 'مذاكرة قواعد الإنجليزي',
        subject: 'اللغة الإنجليزية',
        priority: 2,
        estimatedMinutes: 30,
      ),
    ]);

    exams.add(
      Exam(
        id: 'x1',
        title: 'اختبار الوحدة',
        subject: 'الرياضيات',
        scope: 'المعادلات + الهندسة',
        questionCount: 10,
        type: 'وحدة',
      ),
    );

    reviews.addAll([
      ReviewItem(
        id: 'r1',
        subject: 'الرياضيات',
        topic: 'المعادلات',
        errors: 2,
      ),
      ReviewItem(
        id: 'r2',
        subject: 'اللغة الإنجليزية',
        topic: 'الأزمنة',
        errors: 1,
      ),
    ]);

    flashcards.add(
      Flashcard(
        id: 'f1',
        subject: 'الرياضيات',
        front: 'ما المقصود بالمعادلة؟',
        back: 'مساواة بين تعبيرين رياضيين.',
      ),
    );
  }

  int get completedTasks => tasks.where((e) => e.completed).length;

  double get taskProgress =>
      tasks.isEmpty ? 0 : completedTasks / tasks.length;

  int get totalMinutes =>
      sessions.fold(0, (total, session) => total + session.minutes);

  double get averageExam => exams.isEmpty
      ? 0
      : exams.fold(0, (total, exam) => total + exam.score) / exams.length;

  int get completedLessons => subjects.fold(
        0,
        (total, subject) =>
            total + subject.lessons.where((lesson) => lesson.studied).length,
      );

  int get totalLessons => subjects.fold(
        0,
        (total, subject) => total + subject.lessons.length,
      );

  double get learningProgress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;

  int get level => 1 + (xp ~/ 500);

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();

    await p.setString(
      _key,
      jsonEncode({
        'subjects': subjects.map((e) => e.toJson()).toList(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'exams': exams.map((e) => e.toJson()).toList(),
        'sessions': sessions.map((e) => e.toJson()).toList(),
        'reviews': reviews.map((e) => e.toJson()).toList(),
        'schedule': schedule.map((e) => e.toJson()).toList(),
        'quizAttempts': quizAttempts.map((e) => e.toJson()).toList(),
        'flashcards': flashcards.map((e) => e.toJson()).toList(),
        'themeMode': themeMode,
        'xp': xp,
      }),
    );
  }

  void _changed([int addXp = 0]) {
    xp += addXp;
    notifyListeners();
    _save();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  void addSubject(String name, {String description = ''}) {
    subjects.add(
      Subject(
        id: _id(),
        name: name,
        description: description,
      ),
    );
    _changed(10);
  }

  void deleteSubject(Subject subject) {
    subjects.remove(subject);
    tasks.removeWhere((task) => task.subject == subject.name);
    schedule.removeWhere((item) => item.subject == subject.name);
    flashcards.removeWhere((card) => card.subject == subject.name);
    _changed();
  }

  void addLesson(Subject subject, String title) {
    subject.lessons.add(
      Lesson(
        id: _id(),
        title: title,
      ),
    );
    _changed();
  }

  void toggleLesson(Subject subject, Lesson lesson) {
    lesson.studied = !lesson.studied;
    _changed(lesson.studied ? 20 : 0);
  }

  void updateLessonContent(Lesson lesson, String text) {
    lesson.learnedContent = text;
    _changed(5);
  }

  void toggleTask(StudyTask task) {
    task.completed = !task.completed;
    _changed(task.completed ? 25 : 0);
  }

  void addTask(
    String title,
    String subject, {
    int priority = 2,
    DateTime? dueDate,
    int estimatedMinutes = 25,
  }) {
    tasks.add(
      StudyTask(
        id: _id(),
        title: title,
        subject: subject,
        priority: priority,
        dueDate: dueDate,
        estimatedMinutes: estimatedMinutes,
      ),
    );
    _changed();
  }

  void deleteTask(StudyTask task) {
    tasks.remove(task);
    _changed();
  }

  void addExam(
    String title,
    String subject,
    String scope,
    int count, {
    DateTime? date,
    String type = 'وحدة',
  }) {
    exams.add(
      Exam(
        id: _id(),
        title: title,
        subject: subject,
        scope: scope,
        questionCount: count,
        date: date,
        type: type,
      ),
    );
    _changed();
  }

  void setExamScore(Exam exam, int score) {
    exam.score = score.clamp(0, 100).toInt();
    _changed(10);
  }

  void addSession(String subject, int minutes) {
    sessions.add(
      StudySession(
        id: _id(),
        subject: subject,
        minutes: minutes,
        startedAt: DateTime.now(),
      ),
    );
    _changed(minutes >= 25 ? 50 : 10);
  }

  void addReview(String subject, String topic, int errors) {
    reviews.add(
      ReviewItem(
        id: _id(),
        subject: subject,
        topic: topic,
        errors: errors,
      ),
    );
    _changed();
  }

  void review(ReviewItem item) {
    item.reviewed = true;
    _changed(30);
  }

  void addSchedule(
    String title,
    String subject,
    DateTime start,
    int minutes, {
    bool recurring = false,
  }) {
    schedule.add(
      ScheduleItem(
        id: _id(),
        title: title,
        subject: subject,
        start: start,
        minutes: minutes,
        recurring: recurring,
        weekday: start.weekday,
      ),
    );
    schedule.sort((a, b) => a.start.compareTo(b.start));
    _changed();
  }

  void toggleSchedule(ScheduleItem item) {
    item.completed = !item.completed;
    _changed(item.completed ? 20 : 0);
  }

  void deleteSchedule(ScheduleItem item) {
    schedule.remove(item);
    _changed();
  }

  void addFlashcard(String subject, String front, String back) {
    flashcards.add(
      Flashcard(
        id: _id(),
        subject: subject,
        front: front,
        back: back,
      ),
    );
    _changed(5);
  }

  void practiceFlashcard(Flashcard card) {
    card.repetitions++;
    _changed(5);
  }

  void addQuizAttempt(
    String title,
    String subject,
    int correct,
    int total,
  ) {
    quizAttempts.add(
      QuizAttempt(
        id: _id(),
        title: title,
        subject: subject,
        createdAt: DateTime.now(),
        correct: correct,
        total: total,
      ),
    );

    if (correct < total) {
      addReview(subject, title, total - correct);
    } else {
      _changed(50);
    }
  }

  List<ScheduleItem> scheduleFor(DateTime day) {
    return schedule
        .where(
          (item) =>
              item.start.year == day.year &&
              item.start.month == day.month &&
              item.start.day == day.day,
        )
        .toList();
  }

  List<StudyTask> tasksFor(DateTime day) {
    return tasks
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.year == day.year &&
              task.dueDate!.month == day.month &&
              task.dueDate!.day == day.day,
        )
        .toList();
  }

  List<ScheduleItem> weekFor(DateTime day) {
    final monday = day.subtract(
      Duration(days: day.weekday - 1),
    );

    final start = DateTime(
      monday.year,
      monday.month,
      monday.day,
    );

    final end = start.add(const Duration(days: 7));

    return schedule
        .where(
          (item) =>
              !item.start.isBefore(start) && item.start.isBefore(end),
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  void generateSmartPlan(
    DateTime day, {
    int dailyMinutes = 120,
  }) {
    schedule.removeWhere(
      (item) =>
          item.start.year == day.year &&
          item.start.month == day.month &&
          item.start.day == day.day &&
          item.title.startsWith('خطة ذكية:'),
    );

    final candidates = tasks.where((task) => !task.completed).toList()
      ..sort((a, b) {
        final priority = a.priority.compareTo(b.priority);

        if (priority != 0) {
          return priority;
        }

        return (a.dueDate ?? DateTime(2999)).compareTo(
          b.dueDate ?? DateTime(2999),
        );
      });

    var cursor = DateTime(
      day.year,
      day.month,
      day.day,
      16,
      0,
    );

    var used = 0;

    for (final task in candidates) {
      if (used >= dailyMinutes) {
        break;
      }

      final minutes = task.estimatedMinutes.clamp(15, 60).toInt();

      if (used + minutes > dailyMinutes) {
        continue;
      }

      addSchedule(
        'خطة ذكية: ${task.title}',
        task.subject,
        cursor,
        minutes,
      );

      cursor = cursor.add(
        Duration(minutes: minutes + 10),
      );

      used += minutes;
    }

    lastPlannerMessage = used == 0
        ? 'لا توجد مهام غير مكتملة تحتاج توزيعًا اليوم.'
        : 'تم توزيع $used دقيقة من المهام ذات الأولوية على خطة اليوم.';

    notifyListeners();
  }

  String buildStudyContext() {
    final b = StringBuffer('المواد والدروس:\n');

    for (final subject in subjects) {
      b.writeln('- ${subject.name}:');

      for (final lesson in subject.lessons) {
        b.writeln(
          '  • ${lesson.title} | '
          '${lesson.studied ? 'تمت المذاكرة' : 'لم تتم'} | '
          '${lesson.learnedContent}',
        );
      }
    }

    b.writeln('\nالمهام غير المكتملة:');

    for (final task in tasks.where((item) => !item.completed)) {
      b.writeln('- ${task.title} (${task.subject})');
    }

    b.writeln('\nالاختبارات القادمة:');

    for (final exam in exams.where((item) => item.date != null).take(10)) {
      b.writeln(
        '- ${exam.title} (${exam.subject}) | '
        '${exam.type} | ${exam.date!.toIso8601String()}',
      );
    }

    b.writeln('\nالأخطاء للمراجعة:');

    for (final reviewItem in reviews.where((item) => !item.reviewed)) {
      b.writeln(
        '- ${reviewItem.subject}: '
        '${reviewItem.topic} (${reviewItem.errors} أخطاء)',
      );
    }

    return b.toString();
  }

  void setTheme(String mode) {
    themeMode = mode;
    _changed();
  }
}
