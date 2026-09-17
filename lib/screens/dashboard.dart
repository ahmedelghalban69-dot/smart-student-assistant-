import 'package:flutter/material.dart';

import '../models/study_models.dart';
import '../services/app_state.dart';
import '../widgets/app_header.dart';
import 'ai_page.dart';

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
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            children: [
              const AppHeader(
                title: 'مساعد الطالب الذكي',
                subtitle: 'ذاكر بذكاء، نظم وقتك، وتابع تقدمك',
              ),
              const SizedBox(height: 20),

              _heroCard(context, state),

              const SizedBox(height: 28),

              _sectionTitle(
                context,
                'ابدأ مذاكرتك',
                'كل أدواتك الدراسية في مكان واحد',
              ),

              const SizedBox(height: 13),

              _quickActions(context, state),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: _sectionTitle(
                      context,
                      'خطة اليوم',
                      'ماذا لديك اليوم؟',
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _addSchedule(context, state),
                    child: const Text('إضافة'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (schedule.isEmpty && tasks.isEmpty)
                _emptyToday(context)
              else ...[
                ...schedule.map(
                  (item) =>
                      _scheduleItem(context, state, item),
                ),
                ...tasks.map(
                  (task) =>
                      _taskItem(context, state, task),
                ),
              ],

              const SizedBox(height: 28),

              _sectionTitle(
                context,
                'ملخص تقدمك',
                'أرقام سريعة عن رحلتك الدراسية',
              ),

              const SizedBox(height: 13),

              _stats(context, state),

              const SizedBox(height: 28),

              _sectionTitle(
                context,
                'رحلة التعلم',
                'من أول خطوة حتى الإتقان',
              ),

              const SizedBox(height: 13),

              _learningJourney(context),
            ],
          ),
        );
      },
    );
  }

  Widget _heroCard(
    BuildContext context,
    AppState state,
  ) {
    final colors = Theme.of(context).colorScheme;

    final double progress =
        state.learningProgress
            .clamp(0.0, 1.0)
            .toDouble();

    final percentage =
        (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.primary,
            Color.lerp(
                  colors.primary,
                  colors.secondary,
                  0.60,
                ) ??
                colors.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary
                .withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.16),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'جاهز لمذاكرة أذكى؟ 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'المستوى ${state.level}  •  ${state.xp} XP',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.88),
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تقدمك الدراسي',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                      .withValues(alpha: 0.12),
                ),
                child: Stack(
                  alignment:
                      Alignment.center,
                  children: [
                    SizedBox(
                      width: 62,
                      height: 62,
                      child:
                          CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 7,
                        backgroundColor:
                            Colors.white
                                .withValues(
                                    alpha: 0.15),
                        valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child:
                LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Colors.white
                      .withValues(alpha: 0.16),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 13),

          Text(
            'كل جلسة مذاكرة تقربك خطوة من هدفك ✨',
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: 0.92),
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _quickActions(
    BuildContext context,
    AppState state,
  ) {
    final items = [
      _ActionData(
        title: 'الذكاء الاصطناعي',
        subtitle: 'اسأل، افهم، لخّص',
        icon: Icons.auto_awesome_rounded,
        featured: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AiPage(),
            ),
          );
        },
      ),
      _ActionData(
        title: 'جلسة مذاكرة',
        subtitle: '25 دقيقة تركيز',
        icon: Icons.timer_rounded,
        onTap: () => _startSession(context),
      ),
      _ActionData(
        title: 'اختبار جديد',
        subtitle: 'اختبر فهمك',
        icon: Icons.quiz_rounded,
        onTap: () => _addExam(
          context,
          state,
        ),
      ),
      _ActionData(
        title: 'إضافة مهمة',
        subtitle: 'واجب أو مهمة',
        icon: Icons.task_alt_rounded,
        onTap: () => _addTask(
          context,
          state,
        ),
      ),
      _ActionData(
        title: 'إضافة مادة',
        subtitle: 'نظم موادك',
        icon: Icons.menu_book_rounded,
        onTap: () => _addSubject(
          context,
        ),
      ),
      _ActionData(
        title: 'إضافة جلسة',
        subtitle: 'أضف للخطة',
        icon: Icons.event_available_rounded,
        onTap: () => _addSchedule(
          context,
          state,
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.38,
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
    final colors =
        Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius:
          BorderRadius.circular(23),
      child: InkWell(
        onTap: item.onTap,
        borderRadius:
            BorderRadius.circular(23),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(23),
            gradient: item.featured
                ? LinearGradient(
                    begin:
                        Alignment.topRight,
                    end:
                        Alignment.bottomLeft,
                    colors: [
                      colors.primaryContainer,
                      colors.surface,
                    ],
                  )
                : null,
            border: Border.all(
              color: item.featured
                  ? colors.primary
                      .withValues(alpha: 0.16)
                  : colors.outlineVariant
                      .withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow
                    .withValues(alpha: 0.055),
                blurRadius: 16,
                offset:
                    const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: item.featured
                          ? colors.primary
                          : colors.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.featured
                          ? Colors.white
                          : colors.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: colors.outline,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                item.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
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

  Widget _emptyToday(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer
            .withValues(alpha: 0.38),
        borderRadius:
            BorderRadius.circular(23),
        border: Border.all(
          color: colors.primary
              .withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius:
                  BorderRadius.circular(16),
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
                height: 1.5,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleItem(
    BuildContext context,
    AppState state,
    ScheduleItem item,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    final hour =
        item.start.hour
            .toString()
            .padLeft(2, '0');

    final minute =
        item.start.minute
            .toString()
            .padLeft(2, '0');

    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(21),
        border: Border.all(
          color: colors.outlineVariant
              .withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow
                .withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        leading: Container(
          width: 60,
          height: 60,
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
                  fontWeight:
                      FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${item.minutes} د',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
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
          padding:
              const EdgeInsets.only(top: 5),
          child: Text(item.subject),
        ),
        trailing: IconButton(
          onPressed: () =>
              state.toggleSchedule(item),
          icon: Icon(
            item.completed
                ? Icons.check_circle_rounded
                : Icons.play_circle_fill_rounded,
            color: item.completed
                ? colors.primary
                : colors.secondary,
            size: 29,
          ),
        ),
      ),
    );
  }

  Widget _taskItem(
    BuildContext context,
    AppState state,
    StudyTask task,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(21),
        border: Border.all(
          color: colors.outlineVariant
              .withValues(alpha: 0.55),
        ),
      ),
      child: CheckboxListTile(
        value: task.completed,
        onChanged: (_) =>
            state.toggleTask(task),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        secondary: Container(
          width: 47,
          height: 47,
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
          padding:
              const EdgeInsets.only(top: 4),
          child: Text(
            '${task.subject}  •  أولوية ${task.priority}',
          ),
        ),
      ),
    );
  }

  Widget _stats(
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
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(25),
        border: Border.all(
          color: colors.outlineVariant
              .withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _stat(
              context,
              Icons.school_rounded,
              '${(progress * 100).round()}%',
              'التعلم',
            ),
          ),
          _verticalDivider(context),
          Expanded(
            child: _stat(
              context,
              Icons.task_alt_rounded,
              '${state.completedTasks}',
              'مهام مكتملة',
            ),
          ),
          _verticalDivider(context),
          Expanded(
            child: _stat(
              context,
              Icons.timer_rounded,
              '${state.totalMinutes}',
              'دقيقة مذاكرة',
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    IconData icon,
    String value,
    String title,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: colors.primary,
            size: 21,
          ),
        ),
        const SizedBox(height: 8),
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
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }

  Widget _verticalDivider(
    BuildContext context,
  ) {
    return Container(
      width: 1,
      height: 70,
      color: Theme.of(context)
          .colorScheme
          .outlineVariant
          .withValues(alpha: 0.45),
    );
  }

  Widget _learningJourney(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    final steps = [
      (
        'المحتوى',
        'أضف الدرس والمعلومات',
        Icons.description_outlined,
      ),
      (
        'الفهم',
        'افهم الدرس مع AI',
        Icons.lightbulb_outline_rounded,
      ),
      (
        'التلخيص',
        'حوّل الدرس إلى ملخص',
        Icons.summarize_outlined,
      ),
      (
        'المذاكرة',
        'ذاكر بطريقة منظمة',
        Icons.menu_book_rounded,
      ),
      (
        'الاختبار',
        'اختبر مستوى فهمك',
        Icons.quiz_outlined,
      ),
      (
        'المراجعة',
        'راجع أخطاءك وتقدمك',
        Icons.refresh_rounded,
      ),
    ];

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        17,
        18,
        17,
        8,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(25),
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
                    const EdgeInsets.only(
                  bottom: 13,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color:
                            colors.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: Icon(
                        step.$3,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.$1,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            step.$2,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      index ==
                              steps.length - 1
                          ? Icons.flag_rounded
                          : Icons
                              .arrow_back_ios_new_rounded,
                      size: index ==
                              steps.length - 1
                          ? 19
                          : 14,
                      color: index ==
                              steps.length - 1
                          ? colors.secondary
                          : colors.outline,
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
        title:
            const Text('إضافة مادة'),
        content: TextField(
          controller: controller,
          textDirection:
              TextDirection.rtl,
          autofocus: true,
          decoration:
              const InputDecoration(
            labelText: 'اسم المادة',
            hintText:
                'مثال: الرياضيات',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    dialogContext),
            child:
                const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final name =
                  controller.text.trim();

              if (name.isNotEmpty) {
                AppState.instance
                    .addSubject(name);
              }

              Navigator.pop(
                  dialogContext);
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

    String? subject =
        state.subjects.isEmpty
            ? null
            : state.subjects.first.name;

    showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(
        builder:
            (context, setDialogState) {
          return AlertDialog(
            title:
                const Text('إضافة مهمة'),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      titleController,
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
                if (state.subjects
                    .isNotEmpty)
                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        subject,
                    items: state.subjects
                        .map(
                          (item) =>
                              DropdownMenuItem<
                                  String>(
                            value: item.name,
                            child:
                                Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(
                        () =>
                            subject = value,
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
                    Navigator.pop(
                        dialogContext),
                child:
                    const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final title =
                      titleController
                          .text
                          .trim();

                  if (title.isNotEmpty) {
                    state.addTask(
                      title,
                      subject ??
                          'مذاكرة عامة',
                      dueDate:
                          DateTime.now(),
                    );
                  }

                  Navigator.pop(
                      dialogContext);
                },
                child:
                    const Text('إضافة'),
              ),
            ],
          );
        },
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
        title:
            const Text('اختبار جديد'),
        content: TextField(
          controller: controller,
          textDirection:
              TextDirection.rtl,
          decoration:
              const InputDecoration(
            labelText:
                'اسم الاختبار',
            hintText:
                'مثال: اختبار الرياضيات الأسبوعي',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    dialogContext),
            child:
                const Text('إلغاء'),
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

              Navigator.pop(
                  dialogContext);
            },
            child:
                const Text('إنشاء'),
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
        title: const Text(
          'إضافة جلسة للخطة',
        ),
        content: TextField(
          controller: controller,
          textDirection:
              TextDirection.rtl,
          decoration:
              const InputDecoration(
            labelText:
                'عنوان الجلسة',
            hintText:
                'مثال: مذاكرة درس الجبر',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    dialogContext),
            child:
                const Text('إلغاء'),
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
                  DateTime.now().add(
                    const Duration(
                      hours: 1,
                    ),
                  ),
                  45,
                );
              }

              Navigator.pop(
                  dialogContext);
            },
            child:
                const Text('إضافة'),
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
  const _ActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.featured = false,
  });

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
        (1 - seconds / (25 * 60))
            .clamp(0.0, 1.0)
            .toDouble();

    final colors =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('جلسة مذاكرة'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection:
            TextDirection.rtl,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
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
                      fontWeight:
                          FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                running
                    ? 'حافظ على تركيزك حتى نهاية الجلسة'
                    : '25 دقيقة مذاكرة ثم 5 دقائق راحة',
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                width: 280,
                height: 280,
                decoration:
                    BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors
                      .primaryContainer
                      .withValues(
                        alpha: 0.42,
                      ),
                ),
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Stack(
                  alignment:
                      Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child:
                          CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 13,
                        backgroundColor:
                            colors
                                .outlineVariant
                                .withValues(
                                  alpha: 0.35,
                                ),
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
                          style:
                              TextStyle(
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
                child:
                    FilledButton.icon(
                  onPressed: running
                      ? null
                      : () {
                          setState(
                            () => running =
                                true,
                          );
                          _tick();
                        },
                  icon: const Icon(
                    Icons
                        .play_arrow_rounded,
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
                      seconds =
                          25 * 60;
                      running = false;
                    });
                  },
                  icon: const Icon(
                    Icons
                        .restart_alt_rounded,
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
          setState(
            () => seconds--,
          );
          _tick();
        } else {
          setState(
            () => running = false,
          );

          AppState.instance
              .addSession(
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
