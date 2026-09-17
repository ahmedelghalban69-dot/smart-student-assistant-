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

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            children: [
              const AppHeader(
                title: 'مساعد الطالب الذكي',
                subtitle: 'خطتك، مذاكرتك، واختباراتك في مكان واحد',
              ),

              const SizedBox(height: 16),

              _hero(context, state),

              const SizedBox(height: 22),

              const SectionTitle('ماذا تريد أن تفعل الآن؟'),

              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.35,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _quickAction(
                    context,
                    'إضافة مادة',
                    'ابدأ بتنظيم دراستك',
                    Icons.menu_book_rounded,
                    () => _addSubject(context),
                  ),
                  _quickAction(
                    context,
                    'إضافة مهمة',
                    'سجل واجبك ومهامك',
                    Icons.check_circle_outline_rounded,
                    () => _addTask(context, state),
                  ),
                  _quickAction(
                    context,
                    'جلسة مذاكرة',
                    '25 دقيقة تركيز',
                    Icons.timer_outlined,
                    () => _startSession(context),
                  ),
                  _quickAction(
                    context,
                    'اختبار جديد',
                    'اختبر فهمك',
                    Icons.quiz_outlined,
                    () => _addExam(context, state),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              SectionTitle(
                'خطة اليوم',
                action: 'إضافة موعد',
                onTap: () => _addSchedule(context, state),
              ),

              const SizedBox(height: 10),

              if (todaySchedule.isEmpty && todayTasks.isEmpty)
                _emptyToday(context),

              ...todaySchedule.map(
                (item) => _scheduleTile(context, state, item),
              ),

              ...todayTasks.map(
                (task) => _taskTile(context, state, task),
              ),

              const SizedBox(height: 22),

              const SectionTitle('ملخص تقدمك'),

              const SizedBox(height: 10),

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
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metric(
                      'المهام',
                      '${state.completedTasks}/${state.tasks.length}',
                      Icons.check_circle_rounded,
                      context,
                    ),
                  ),
                  const SizedBox(width: 10),
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

              const SizedBox(height: 22),

              const SectionTitle('رحلة الدراسة'),

              const SizedBox(height: 10),

              _studyJourney(context),
            ],
          ),
        );
      },
    );
  }

  Widget _hero(BuildContext context, AppState state) {
    final progress = state.learningProgress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جاهز لمذاكرة أذكى؟',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'مستوى ${state.level} • ${state.xp} XP',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'أكملت ${(progress * 100).round()}% من التعلم و'
            '${(state.taskProgress * 100).round()}% من المهام.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 11),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            'كل خطوة صغيرة تقربك من هدفك الكبير ✨',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyToday(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'لا توجد عناصر مجدولة اليوم.\nأضف مهمة أو جلسة مذاكرة وابدأ.',
              style: TextStyle(
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskTile(
    BuildContext context,
    AppState state,
    StudyTask task,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      child: CheckboxListTile(
        value: task.completed,
        onChanged: (_) {
          state.toggleTask(task);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.assignment_turned_in_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration:
                task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${task.subject} • أولوية ${task.priority}',
          ),
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
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '${item.start.hour}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${item.subject} • ${item.minutes} دقيقة',
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            state.toggleSchedule(item);
          },
          icon: Icon(
            item.completed
                ? Icons.check_circle_rounded
                : Icons.play_circle_outline_rounded,
            color: item.completed
                ? Theme.of(context).colorScheme.primary
                : null,
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
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 7,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 25,
            ),

            const SizedBox(height: 7),

            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studyJourney(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final steps = [
      ('إضافة المحتوى', Icons.add_box_outlined),
      ('تنظيمه', Icons.calendar_month_outlined),
      ('فهمه', Icons.lightbulb_outline_rounded),
      ('تلخيصه', Icons.summarize_outlined),
      ('مذاكرته', Icons.menu_book_rounded),
      ('اختباره', Icons.quiz_outlined),
      ('مراجعة الأخطاء', Icons.refresh_rounded),
      ('متابعة التقدم', Icons.insights_rounded),
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'رحلتك الدراسية في مكان واحد',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),

            const SizedBox(height: 16),

            ...List.generate(
              steps.length,
              (index) {
                final step = steps[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          step.$2,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Text(
                          step.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      if (index < steps.length - 1)
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 14,
                        ),
                    ],
                  ),
                );
              },
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
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم المادة',
              hintText: 'مثال: الرياضيات',
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
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'المهمة',
                      hintText: 'مثال: حل واجب الرياضيات',
                    ),
                  ),

                  const SizedBox(height: 12),

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
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم الاختبار',
              hintText: 'مثال: اختبار الرياضيات الأسبوعي',
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
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'عنوان الجلسة',
              hintText: 'مثال: مذاكرة درس الجبر',
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

    final progress =
        1 - (seconds / (25 * 60));

    return Scaffold(
      appBar: AppBar(
        title: const Text('جلسة مذاكرة'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  running ? 'ركز الآن 🎯' : 'جاهز نبدأ؟',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  running
                      ? 'حافظ على تركيزك حتى نهاية الجلسة'
                      : '25 دقيقة مذاكرة ثم 5 دقائق راحة',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: 235,
                  height: 235,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 235,
                        height: 235,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 12,
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$minutes:$remainingSeconds',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('وقت المذاكرة'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: running
                        ? null
                        : () {
                            setState(() {
                              running = true;
                            });

                            _tick();
                          },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    label: const Text(
                      'بدء جلسة المذاكرة',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        seconds = 25 * 60;
                        running = false;
                      });
                    },
                    icon: const Icon(
                      Icons.restart_alt_rounded,
                    ),
                    label: const Text('إعادة ضبط'),
                  ),
                ),
              ],
            ),
          ),
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
