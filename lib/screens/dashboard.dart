import 'package:flutter/material.dart';

import '../models/study_models.dart';
import '../services/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/section_title.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (_, __) {
        final state = AppState.instance;
        final today = DateTime.now();
        final todayTasks = state.tasksFor(today);
        final todaySchedule = state.scheduleFor(today);

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const AppHeader(
              title: 'مساعد الطالب الذكي',
              subtitle: 'مساعدك الدراسي الشامل بالذكاء الاصطناعي',
            ),
            const SizedBox(height: 18),
            _hero(context, state),
            const SizedBox(height: 18),
            const SectionTitle('اختصارات سريعة'),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _quickAction(
                  'إضافة مادة',
                  Icons.menu_book,
                  () => _addSubject(context),
                ),
                _quickAction(
                  'إضافة مهمة',
                  Icons.task_alt,
                  () => _addTask(context, state),
                ),
                _quickAction(
                  'جلسة مذاكرة',
                  Icons.timer,
                  () => _startSession(context),
                ),
                _quickAction(
                  'اختبار جديد',
                  Icons.quiz,
                  () => _addExam(context, state),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SectionTitle(
              'اليوم',
              action: 'إضافة موعد',
              onTap: () => _addSchedule(context, state),
            ),
            if (todaySchedule.isEmpty && todayTasks.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'لا توجد عناصر مجدولة اليوم. أضف مهمة أو جلسة مذاكرة وابدأ.',
                  ),
                ),
              ),
            ...todaySchedule.map(
              (item) => _scheduleTile(context, state, item),
            ),
            ...todayTasks.map(
              (task) => _taskTile(context, state, task),
            ),
            const SizedBox(height: 18),
            const SectionTitle('نظرة سريعة'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _metric(
                    'تقدم التعلم',
                    '${(state.learningProgress * 100).round()}%',
                    Icons.school_rounded,
                    context,
                  ),
                ),
                Expanded(
                  child: _metric(
                    'المهام',
                    '${state.completedTasks}/${state.tasks.length}',
                    Icons.check_circle,
                    context,
                  ),
                ),
                Expanded(
                  child: _metric(
                    'المذاكرة',
                    '${state.totalMinutes} د',
                    Icons.timer_rounded,
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const SectionTitle('رحلة الدراسة'),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'إضافة المحتوى  →  تنظيمه  →  فهمه  →  تلخيصه  →  مذاكرته  →  اختباره  →  مراجعة الأخطاء  →  متابعة التقدم',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _hero(BuildContext context, AppState state) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor:
                  Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مستوى ${state.level} • ${state.xp} XP',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أكملت ${(state.learningProgress * 100).round()}% من الدروس و${(state.taskProgress * 100).round()}% من المهام.',
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: state.learningProgress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskTile(
    BuildContext context,
    AppState state,
    StudyTask task,
  ) {
    return Card(
      child: CheckboxListTile(
        value: task.completed,
        onChanged: (_) {
          state.toggleTask(task);
        },
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text(
          '${task.subject} • أولوية ${task.priority}',
        ),
      ),
    );
  }

  Widget _scheduleTile(
    BuildContext context,
    AppState state,
    ScheduleItem item,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${item.start.hour}'),
        ),
        title: Text(item.title),
        subtitle: Text(
          '${item.subject} • ${item.minutes} دقيقة',
        ),
        trailing: IconButton(
          onPressed: () {
            state.toggleSchedule(item);
          },
          icon: Icon(
            item.completed
                ? Icons.check_circle
                : Icons.play_circle_outline,
          ),
        ),
      ),
    );
  }

  Widget _metric(
    String title,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _addSubject(BuildContext context) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة مادة'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'اسم المادة',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isNotEmpty) {
                  AppState.instance.addSubject(name);
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _addTask(
    BuildContext context,
    AppState state,
  ) {
    final titleController = TextEditingController();

    String? subject = state.subjects.isEmpty
        ? null
        : state.subjects.first.name;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('إضافة مهمة'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'المهمة',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (state.subjects.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: subject,
                      items: state.subjects
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.name,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          subject = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'المادة',
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();

                    if (title.isNotEmpty) {
                      state.addTask(
                        title,
                        subject ?? 'مذاكرة عامة',
                        dueDate: DateTime.now(),
                      );
                    }

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startSession(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _SessionPage(),
      ),
    );
  }

  void _addExam(
    BuildContext context,
    AppState state,
  ) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('اختبار جديد'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'اسم الاختبار',
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                final title = controller.text.trim();

                if (title.isNotEmpty) {
                  state.addExam(
                    title,
                    state.subjects.isEmpty
                        ? 'عام'
                        : state.subjects.first.name,
                    'كل الدروس',
                    10,
                  );
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('إنشاء'),
            ),
          ],
        );
      },
    );
  }

  void _addSchedule(
    BuildContext context,
    AppState state,
  ) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة جلسة للخطة'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'عنوان الجلسة',
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                final title = controller.text.trim();

                if (title.isNotEmpty) {
                  state.addSchedule(
                    title,
                    state.subjects.isEmpty
                        ? 'عام'
                        : state.subjects.first.name,
                    DateTime.now().add(
                      const Duration(hours: 1),
                    ),
                    45,
                  );
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }
}

class _SessionPage extends StatefulWidget {
  const _SessionPage();

  @override
  State<_SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<_SessionPage> {
  int seconds = 25 * 60;
  bool running = false;

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final remainingSeconds =
        (seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('جلسة مذاكرة'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutes:$remainingSeconds',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: running
                  ? null
                  : () {
                      setState(() {
                        running = true;
                      });
                      _tick();
                    },
              icon: const Icon(Icons.play_arrow),
              label: const Text('بدء جلسة 25 دقيقة'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  seconds = 25 * 60;
                  running = false;
                });
              },
              child: const Text('إعادة'),
            ),
          ],
        ),
      ),
    );
  }

  void _tick() {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (!mounted || !running) {
          return;
        }

        if (seconds > 0) {
          setState(() {
            seconds--;
          });
          _tick();
        } else {
          setState(() {
            running = false;
          });

          AppState.instance.addSession(
            'جلسة عامة',
            25,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'انتهت الجلسة 🎉 حان وقت الراحة 5 دقائق.',
              ),
            ),
          );
        }
      },
    );
  }
}
