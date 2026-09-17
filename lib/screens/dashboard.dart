import 'package:flutter/material.dart';

import '../models/study_models.dart';
import '../services/app_state.dart';
import '../widgets/app_header.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final state = AppState.instance;
        final today = DateTime.now();
        final tasks = state.tasksFor(today);
        final schedule = state.scheduleFor(today);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              const AppHeader(
                title: 'مساعد الطالب الذكي',
                subtitle: 'كل ما تحتاجه للمذاكرة في مكان واحد',
              ),
              const SizedBox(height: 18),
              _welcomeCard(context, state),
              const SizedBox(height: 24),
              _sectionHeader(
                context,
                'ابدأ من هنا',
                'أدواتك الأساسية للمذاكرة',
              ),
              const SizedBox(height: 12),
              _actionsGrid(context, state),
              const SizedBox(height: 24),
              _todayHeader(context, state),
              const SizedBox(height: 12),
              if (schedule.isEmpty && tasks.isEmpty)
                _emptyToday(context)
              else ...[
                ...schedule.map(
                  (item) => _scheduleCard(context, state, item),
                ),
                ...tasks.map(
                  (task) => _taskCard(context, state, task),
                ),
              ],
              const SizedBox(height: 24),
              _sectionHeader(
                context,
                'إنجازك اليوم',
                'نظرة سريعة على تقدمك',
              ),
              const SizedBox(height: 12),
              _statsCard(context, state),
              const SizedBox(height: 24),
              _sectionHeader(
                context,
                'رحلتك الدراسية',
                'من المحتوى إلى الإتقان',
              ),
              const SizedBox(height: 12),
              _journeyCard(context),
            ],
          ),
        );
      },
    );
  }

  Widget _welcomeCard(BuildContext context, AppState state) {
    final colors = Theme.of(context).colorScheme;

    final double progress =
        state.learningProgress.clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.primary,
            Color.lerp(
                  colors.primary,
                  colors.secondary,
                  0.55,
                ) ??
                colors.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'جاهز لمذاكرة أذكى؟ 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'المستوى ${state.level}  •  ${state.xp} XP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'تقدم التعلم ${(progress * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'كل جلسة مذاكرة تقربك خطوة من هدفك ✨',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsGrid(
    BuildContext context,
    AppState state,
  ) {
    final items = [
      _ActionData(
        'اسأل الذكاء الاصطناعي',
        'شرح، تلخيص وحل واجب',
        Icons.auto_awesome_rounded,
        () {},
        true,
      ),
      _ActionData(
        'جلسة مذاكرة',
        '25 دقيقة تركيز',
        Icons.timer_rounded,
        () => _startSession(context),
        false,
      ),
      _ActionData(
        'اختبار جديد',
        'اختبر فهمك',
        Icons.quiz_rounded,
        () => _addExam(context, state),
        false,
      ),
      _ActionData(
        'إضافة مهمة',
        'واجب أو مهمة دراسية',
        Icons.task_alt_rounded,
        () => _addTask(context, state),
        false,
      ),
      _ActionData(
        'إضافة مادة',
        'نظم موادك ودروسك',
        Icons.menu_book_rounded,
        () => _addSubject(context),
        false,
      ),
      _ActionData(
        'إضافة موعد',
        'أضف جلسة للخطة',
        Icons.event_available_rounded,
        () => _addSchedule(context, state),
        false,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        return _actionCard(
          context,
          items[index],
        );
      },
    );
  }

  Widget _actionCard(
    BuildContext context,
    _ActionData item,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.outlineVariant
                  .withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.featured
                          ? colors.primary
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.featured
                          ? Colors.white
                          : colors.primary,
                      size: 23,
                    ),
                  ),
                  const Spacer(),
                  if (item.featured)
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _todayHeader(
    BuildContext context,
    AppState state,
  ) {
    return Row(
      children: [
        Expanded(
          child: _sectionHeader(
            context,
            'خطة اليوم',
            'مهامك وجلساتك القادمة',
          ),
        ),
        TextButton.icon(
          onPressed: () =>
              _addSchedule(context, state),
          icon: const Icon(
            Icons.add_rounded,
            size: 20,
          ),
          label: const Text('إضافة'),
        ),
      ],
    );
  }

  Widget _emptyToday(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer
            .withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.primaryContainer,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.event_note_rounded,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'يومك لسه فاضي 👌\n'
              'أضف مهمة أو جلسة مذاكرة وابدأ.',
              style: TextStyle(
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard(
    BuildContext context,
    AppState state,
    ScheduleItem item,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    final hour =
        item.start.hour.toString().padLeft(2, '0');

    final minute =
        item.start.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius:
                BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                '$hour:$minute',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.minutes} د',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(item.subject),
        ),
        trailing: IconButton(
          tooltip:
              item.completed ? 'تم الإنجاز' : 'بدء',
          onPressed: () =>
              state.toggleSchedule(item),
          icon: Icon(
            item.completed
                ? Icons.check_circle_rounded
                : Icons.play_circle_fill_rounded,
            color: item.completed
                ? colors.primary
                : colors.secondary,
          ),
        ),
      ),
    );
  }

  Widget _taskCard(
    BuildContext context,
    AppState state,
    StudyTask task,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: CheckboxListTile(
        value: task.completed,
        onChanged: (_) =>
            state.toggleTask(task),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        secondary: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius:
                BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.assignment_turned_in_rounded,
            color: colors.secondary,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            decoration: task.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${task.subject}  •  أولوية ${task.priority}',
          ),
        ),
      ),
    );
  }

  Widget _statsCard(
    BuildContext context,
    AppState state,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    final double progress =
        state.learningProgress
            .clamp(0.0, 1.0)
            .toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant
              .withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statItem(
                  context,
                  'التعلم',
                  '${(progress * 100).round()}%',
                  Icons.school_rounded,
                ),
              ),
              _divider(context),
              Expanded(
                child: _statItem(
                  context,
                  'المهام',
                  '${state.completedTasks}/${state.tasks.length}',
                  Icons.task_alt_rounded,
                ),
              ),
              _divider(context),
              Expanded(
                child: _statItem(
                  context,
                  'المذاكرة',
                  '${state.totalMinutes} د',
                  Icons.timer_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          color: colors.primary,
          size: 23,
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
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }

  Widget _divider(
    BuildContext context,
  ) {
    return Container(
      width: 1,
      height: 48,
      color: Theme.of(context)
          .colorScheme
          .outlineVariant
          .withValues(alpha: 0.5),
    );
  }

  Widget _journeyCard(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    final steps = [
      (
        'المحتوى',
        Icons.description_outlined,
      ),
      (
        'الفهم',
        Icons.lightbulb_outline_rounded,
      ),
      (
        'التلخيص',
        Icons.summarize_outlined,
      ),
      (
        'المذاكرة',
        Icons.menu_book_rounded,
      ),
      (
        'الاختبار',
        Icons.quiz_outlined,
      ),
      (
        'المراجعة',
        Icons.refresh_rounded,
      ),
    ];

    return Container(
      padding:
          const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant
              .withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          ...List.generate(
            steps.length,
            (index) {
              final step = steps[index];

              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            colors.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Icon(
                        step.$2,
                        color: colors.primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (index < steps.length - 1)
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: colors.outline,
                      )
                    else
                      Icon(
                        Icons.flag_rounded,
                        size: 18,
                        color: colors.secondary,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addSubject(
    BuildContext context,
  ) {
    final controller =
        TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
        title: const Text('إضافة مادة'),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          autofocus: true,
          decoration:
              const InputDecoration(
            labelText: 'اسم المادة',
            hintText: 'مثال: الرياضيات',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final name =
                  controller.text.trim();

              if (name.isNotEmpty) {
                AppState.instance.addSubject(name);
              }

              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addTask(
    BuildContext context,
    AppState state,
  ) {
    final titleController =
        TextEditingController();

    String? subject = state.subjects.isEmpty
        ? null
        : state.subjects.first.name;

    showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder:
            (context, setDialogState) =>
                AlertDialog(
          title: const Text('إضافة مهمة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                textDirection:
                    TextDirection.rtl,
                decoration:
                    const InputDecoration(
                  labelText: 'المهمة',
                  hintText:
                      'مثال: حل واجب الرياضيات',
                ),
              ),
              const SizedBox(height: 12),
              if (state.subjects.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: subject,
                  items: state.subjects
                      .map(
                        (item) =>
                            DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setDialogState(
                      () => subject = value,
                    );
                  },
                  decoration:
                      const InputDecoration(
                    labelText: 'المادة',
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final title =
                    titleController.text.trim();

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
        ),
      ),
    );
  }

  void _addExam(
    BuildContext context,
    AppState state,
  ) {
    final controller =
        TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
        title: const Text('اختبار جديد'),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          decoration:
              const InputDecoration(
            labelText: 'اسم الاختبار',
            hintText:
                'مثال: اختبار الرياضيات الأسبوعي',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final title =
                  controller.text.trim();

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
      ),
    );
  }

  void _addSchedule(
    BuildContext context,
    AppState state,
  ) {
    final controller =
        TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
        title:
            const Text('إضافة جلسة للخطة'),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          decoration:
              const InputDecoration(
            labelText: 'عنوان الجلسة',
            hintText:
                'مثال: مذاكرة درس الجبر',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final title =
                  controller.text.trim();

              if (title.isNotEmpty) {
                state.addSchedule(
                  title,
                  state.subjects.isEmpty
                      ? 'عام'
                      : state.subjects.first.name,
                  DateTime.now()
                      .add(const Duration(hours: 1)),
                  45,
                );
              }

              Navigator.pop(dialogContext);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _startSession(
    BuildContext context,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const _SessionPage(),
      ),
    );
  }
}

class _ActionData {
  const _ActionData(
    this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.featured,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool featured;
}

class _SessionPage extends StatefulWidget {
  const _SessionPage();

  @override
  State<_SessionPage> createState() =>
      _SessionPageState();
}

class _SessionPageState
    extends State<_SessionPage> {
  int seconds = 25 * 60;
  bool running = false;

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;

    final remainingSeconds =
        (seconds % 60)
            .toString()
            .padLeft(2, '0');

    final double progress =
        (1 - (seconds / (25 * 60)))
            .clamp(0.0, 1.0)
            .toDouble();

    final colors =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('جلسة مذاكرة'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                running
                    ? 'ركز الآن 🎯'
                    : 'جاهز نبدأ؟',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                running
                    ? 'حافظ على تركيزك حتى نهاية الجلسة'
                    : '25 دقيقة مذاكرة ثم 5 دقائق راحة',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryContainer
                      .withValues(alpha: 0.42),
                ),
                padding: const EdgeInsets.all(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child:
                          CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 13,
                        backgroundColor:
                            colors.outlineVariant
                                .withValues(alpha: 0.35),
                      ),
                    ),
                    Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          '$minutes:$remainingSeconds',
                          style:
                              const TextStyle(
                            fontSize: 52,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'دقيقة تركيز',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: running
                      ? null
                      : () {
                          setState(
                            () => running = true,
                          );
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
                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      seconds = 25 * 60;
                      running = false;
                    });
                  },
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                  ),
                  label: const Text(
                    'إعادة ضبط',
                  ),
                ),
              ),
            ],
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
          setState(() => seconds--);
          _tick();
        } else {
          setState(() => running = false);

          AppState.instance.addSession(
            'جلسة عامة',
            25,
          );

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'انتهت الجلسة 🎉 '
                'حان وقت الراحة 5 دقائق.',
              ),
            ),
          );
        }
      },
    );
  }
}
