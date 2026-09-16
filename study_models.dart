class Subject {
  final String id;
  String name;
  String description;
  final List<Lesson> lessons;
  Subject({required this.id, required this.name, this.description = '', List<Lesson>? lessons}) : lessons = lessons ?? [];
  double get progress => lessons.isEmpty ? 0 : lessons.where((l) => l.studied).length / lessons.length;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description, 'lessons': lessons.map((e) => e.toJson()).toList()};
  factory Subject.fromJson(Map<String, dynamic> j) => Subject(id: j['id'] ?? '', name: j['name'] ?? '', description: j['description'] ?? '', lessons: (j['lessons'] as List? ?? []).map((e) => Lesson.fromJson(Map<String, dynamic>.from(e))).toList());
}
class Lesson {
  final String id;
  String title;
  String learnedContent;
  bool studied;
  Lesson({required this.id, required this.title, this.learnedContent = '', this.studied = false});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'learnedContent': learnedContent, 'studied': studied};
  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(id: j['id'] ?? '', title: j['title'] ?? '', learnedContent: j['learnedContent'] ?? '', studied: j['studied'] ?? false);
}
class StudyTask {
  final String id;
  String title;
  String subject;
  DateTime? dueDate;
  bool completed;
  int priority;
  int estimatedMinutes;
  StudyTask({required this.id, required this.title, required this.subject, this.dueDate, this.completed = false, this.priority = 2, this.estimatedMinutes = 25});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'subject': subject, 'dueDate': dueDate?.toIso8601String(), 'completed': completed, 'priority': priority, 'estimatedMinutes': estimatedMinutes};
  factory StudyTask.fromJson(Map<String, dynamic> j) => StudyTask(id: j['id'] ?? '', title: j['title'] ?? '', subject: j['subject'] ?? '', dueDate: j['dueDate'] == null ? null : DateTime.tryParse(j['dueDate']), completed: j['completed'] ?? false, priority: j['priority'] ?? 2, estimatedMinutes: j['estimatedMinutes'] ?? 25);
}
class Exam {
  final String id;
  String title;
  String subject;
  String scope;
  int questionCount;
  DateTime? date;
  int score;
  String type;
  Exam({required this.id, required this.title, required this.subject, this.scope = '', this.questionCount = 10, this.date, this.score = 0, this.type = 'وحدة'});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'subject': subject, 'scope': scope, 'questionCount': questionCount, 'date': date?.toIso8601String(), 'score': score, 'type': type};
  factory Exam.fromJson(Map<String, dynamic> j) => Exam(id: j['id'] ?? '', title: j['title'] ?? '', subject: j['subject'] ?? '', scope: j['scope'] ?? '', questionCount: j['questionCount'] ?? 10, date: j['date'] == null ? null : DateTime.tryParse(j['date']), score: j['score'] ?? 0, type: j['type'] ?? 'وحدة');
}
class StudySession {
  final String id;
  final String subject;
  final int minutes;
  final DateTime startedAt;
  StudySession({required this.id, required this.subject, required this.minutes, required this.startedAt});
  Map<String, dynamic> toJson() => {'id': id, 'subject': subject, 'minutes': minutes, 'startedAt': startedAt.toIso8601String()};
  factory StudySession.fromJson(Map<String, dynamic> j) => StudySession(id: j['id'] ?? '', subject: j['subject'] ?? '', minutes: j['minutes'] ?? 0, startedAt: DateTime.tryParse(j['startedAt'] ?? '') ?? DateTime.now());
}
class ReviewItem {
  final String id;
  final String subject;
  final String topic;
  int errors;
  bool reviewed;
  ReviewItem({required this.id, required this.subject, required this.topic, this.errors = 1, this.reviewed = false});
  Map<String, dynamic> toJson() => {'id': id, 'subject': subject, 'topic': topic, 'errors': errors, 'reviewed': reviewed};
  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem(id: j['id'] ?? '', subject: j['subject'] ?? '', topic: j['topic'] ?? '', errors: j['errors'] ?? 1, reviewed: j['reviewed'] ?? false);
}
class ScheduleItem {
  final String id;
  String title;
  String subject;
  DateTime start;
  int minutes;
  bool completed;
  bool recurring;
  int? weekday;
  ScheduleItem({required this.id, required this.title, required this.subject, required this.start, this.minutes = 45, this.completed = false, this.recurring = false, this.weekday});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'subject': subject, 'start': start.toIso8601String(), 'minutes': minutes, 'completed': completed, 'recurring': recurring, 'weekday': weekday};
  factory ScheduleItem.fromJson(Map<String, dynamic> j) => ScheduleItem(id: j['id'] ?? '', title: j['title'] ?? '', subject: j['subject'] ?? '', start: DateTime.tryParse(j['start'] ?? '') ?? DateTime.now(), minutes: j['minutes'] ?? 45, completed: j['completed'] ?? false, recurring: j['recurring'] ?? false, weekday: j['weekday']);
}
class QuizQuestion {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  QuizQuestion({required this.id, required this.text, required this.options, required this.correctIndex, this.explanation = ''});
  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'options': options, 'correctIndex': correctIndex, 'explanation': explanation};
  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(id: j['id'] ?? '', text: j['text'] ?? '', options: (j['options'] as List? ?? []).map((e) => e.toString()).toList(), correctIndex: j['correctIndex'] ?? 0, explanation: j['explanation'] ?? '');
}
class QuizAttempt {
  final String id;
  final String title;
  final String subject;
  final DateTime createdAt;
  final int correct;
  final int total;
  QuizAttempt({required this.id, required this.title, required this.subject, required this.createdAt, required this.correct, required this.total});
  int get score => total == 0 ? 0 : ((correct / total) * 100).round();
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'subject': subject, 'createdAt': createdAt.toIso8601String(), 'correct': correct, 'total': total};
  factory QuizAttempt.fromJson(Map<String, dynamic> j) => QuizAttempt(id: j['id'] ?? '', title: j['title'] ?? '', subject: j['subject'] ?? '', createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(), correct: j['correct'] ?? 0, total: j['total'] ?? 0);
}
class Flashcard {
  final String id;
  final String subject;
  final String front;
  final String back;
  int repetitions;
  Flashcard({required this.id, required this.subject, required this.front, required this.back, this.repetitions = 0});
  Map<String, dynamic> toJson() => {'id': id, 'subject': subject, 'front': front, 'back': back, 'repetitions': repetitions};
  factory Flashcard.fromJson(Map<String, dynamic> j) => Flashcard(id: j['id'] ?? '', subject: j['subject'] ?? '', front: j['front'] ?? '', back: j['back'] ?? '', repetitions: j['repetitions'] ?? 0);
}
