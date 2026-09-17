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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  constraints.maxWidth > 800 ? 40 : 18,
                  18,
                  constraints.maxWidth > 800 ? 40 : 18,
                  32,
                ),
                children: [
                  const AppHeader(
                    title: 'مساعد الطالب الذكي',
                    subtitle: 'خطتك، موادك، مذاكرتك وذكاؤك الاصطناعي في مكان واحد',
                  ),

                  const SizedBox(height: 22),

                  _HeroSection(
                    state: state,
                    onAiPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AiPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  _SectionHeader(
                    title: 'ابدأ مذاكرتك',
                    subtitle: 'كل الأدوات التي تحتاجها في خطوات بسيطة',
                  ),

                  const SizedBox(height: 14),

                  _ToolsGrid(
                    wide: constraints.maxWidth > 800,
                    onAiPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AiPage(),
                        ),
                      );
                    },
                    onStudyPressed: () => _startSession(context),
                    onQuizPressed: () => _addExam(context, state),
                    onTaskPressed: () => _addTask(context, state),
                    onSubjectPressed: () => _addSubject(context),
                    onSchedulePressed: () => _addSchedule(context, state),
                  ),

                  const SizedBox(height: 30),

                  _SectionHeader(
                    title: 'خطة اليوم',
                    subtitle: 'اعرف ماذا عليك أن تنجز الآن',
                    action: TextButton.icon(
                      onPressed: () => _addSchedule(context, state),
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 19,
                      ),
                      label: const Text('إضافة'),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (schedule.isEmpty && tasks.isEmpty)
                    const _EmptyToday()
                  else ...[
                    ...schedule.map(
                      (item) => _ScheduleCard(
                        item: item,
                        onToggle: () => state.toggleSchedule(item),
                      ),
                    ),
                    ...tasks.map(
                      (task) => _TaskCard(
                        task: task,
                        onToggle: () => state.toggleTask(task),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  _SectionHeader(
                    title: 'إنجازك',
                    subtitle: 'نظرة سريعة على تقدمك الدراسي',
                  ),

                  const SizedBox(height: 14),

                  _ProgressOverview(state: state),

                  const SizedBox(height: 30),

                  _SectionHeader(
                    title: 'رحلة الإتقان',
                    subtitle: 'المحتوى يتحول إلى معرفة ثم إلى إتقان',
                  ),

                  const SizedBox(height: 14),

                  const _StudyJourney(),
                ],
              );
            },
          ),
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

  void _addSubject(BuildContext context) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة مادة'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم المادة',
              hintText: 'مثال: الرياضيات',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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

    String? subject =
        state.subjects.isEmpty ? null : state.subjects.first.name;

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
                  const SizedBox(height: 14),
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
                  onPressed: () => Navigator.pop(dialogContext),
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
            autofocus: true,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم الاختبار',
              hintText: 'مثال: اختبار الرياضيات الأسبوعي',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
            autofocus: true,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'عنوان الجلسة',
              hintText: 'مثال: مذاكرة درس الجبر',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.state,
    required this.onAiPressed,
  });

  final AppState state;
  final VoidCallback onAiPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final double progress =
        state.learningProgress.clamp(0.0, 1.0).toDouble();

    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.primary,
            Color.lerp(
                  colors.primary,
                  colors.secondary,
                  0.65,
                ) ??
                colors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 14),
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
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
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
                      'مساحتك الدراسية الذكية',
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
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تقدمك الدراسي',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              _ProgressRing(
                value: progress,
              ),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Text(
                  'ابدأ من حيث أنت، ودع التطبيق يساعدك في تنظيم طريقك.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.90),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onAiPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                child: const Text(
                  'ابدأ مع AI',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.value,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 6,
            backgroundColor:
                Colors.white.withValues(alpha: 0.16),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid({
    required this.wide,
    required this.onAiPressed,
    required this.onStudyPressed,
    required this.onQuizPressed,
    required this.onTaskPressed,
    required this.onSubjectPressed,
    required this.onSchedulePressed,
  });

  final bool wide;
  final VoidCallback onAiPressed;
  final VoidCallback onStudyPressed;
  final VoidCallback onQuizPressed;
  final VoidCallback onTaskPressed;
  final VoidCallback onSubjectPressed;
  final VoidCallback onSchedulePressed;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ToolData(
        title: 'الذكاء الاصطناعي',
        subtitle: 'اسأل، افهم، لخّص، وحل',
        icon: Icons.auto_awesome_rounded,
        featured: true,
        onTap: onAiPressed,
      ),
      _ToolData(
        title: 'جلسة مذاكرة',
        subtitle: '25 دقيقة تركيز',
        icon: Icons.timer_rounded,
        onTap: onStudyPressed,
      ),
      _ToolData(
        title: 'اختبار جديد',
        subtitle: 'اختبر فهمك',
        icon: Icons.quiz_rounded,
        onTap: onQuizPressed,
      ),
      _ToolData(
        title: 'مهمة جديدة',
        subtitle: 'واجب أو هدف دراسي',
        icon: Icons.task_alt_rounded,
        onTap: onTaskPressed,
      ),
      _ToolData(
        title: 'إضافة مادة',
        subtitle: 'أنشئ مادة ودروسها',
        icon: Icons.menu_book_rounded,
        onTap: onSubjectPressed,
      ),
      _ToolData(
        title: 'إضافة جلسة',
        subtitle: 'نظّم وقتك',
        icon: Icons.event_available_rounded,
        onTap: onSchedulePressed,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 3 : 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: wide ? 1.55 : 1.22,
      ),
      itemBuilder: (context, index) {
        return _ToolCard(
          data: items[index],
        );
      },
    );
  }
}

class _ToolData {
  const _ToolData({
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

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.data,
  });

  final _ToolData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final background = data.featured
        ? colors.primary
        : colors.surface;

    final foreground =
        data.featured ? Colors.white : colors.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: data.featured
                ? null
                : Border.all(
                    color: colors.outlineVariant.withValues(
                      alpha: 0.50,
                    ),
                  ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(
                  alpha: data.featured ? 0.16 : 0.05,
                ),
                blurRadius: data.featured ? 22 : 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: data.featured
                          ? Colors.white.withValues(alpha: 0.15)
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      data.icon,
                      color: data.featured
                          ? Colors.white
                          : colors.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: data.featured
                        ? Colors.white.withValues(alpha: 0.85)
                        : colors.outline,
                    size: 19,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: data.featured
                      ? Colors.white.withValues(alpha: 0.78)
                      : colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.primaryContainer,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.event_note_rounded,
              color: colors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'يومك لسه فاضي',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'أضف مهمة أو جلسة مذاكرة وابدأ تنظيم يومك.',
                  style: TextStyle(
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.item,
    required this.onToggle,
  });

  final ScheduleItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hour = item.start.hour.toString().padLeft(2, '0');
    final minute = item.start.minute.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.48),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: Container(
          width: 62,
          height: 58,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$hour:$minute',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
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
          child: Text(
            item.subject,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: IconButton(
          onPressed: onToggle,
          tooltip: item.completed ? 'تم الإنجاز' : 'بدء الجلسة',
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
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onToggle,
  });

  final StudyTask task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.48),
        ),
      ),
      child: CheckboxListTile(
        value: task.completed,
        onChanged: (_) => onToggle(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        secondary: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(15),
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
            decoration:
                task.completed ? TextDecoration.lineThrough : null,
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
}

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview({
    required this.state,
  });

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final progress =
        state.learningProgress.clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.50),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: Icons.school_rounded,
                  title: 'التعلم',
                  value: '${(progress * 100).round()}%',
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _Stat(
                  icon: Icons.task_alt_rounded,
                  title: 'المهام',
                  value:
                      '${state.completedTasks}/${state.tasks.length}',
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _Stat(
                  icon: Icons.timer_rounded,
                  title: 'المذاكرة',
                  value: '${state.totalMinutes} د',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: Theme.of(context)
          .colorScheme
          .outlineVariant
          .withValues(alpha: 0.55),
    );
  }
}

class _StudyJourney extends StatelessWidget {
  const _StudyJourney();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    const steps = [
      ('المحتوى', Icons.description_outlined),
      ('الفهم', Icons.lightbulb_outline_rounded),
      ('التلخيص', Icons.summarize_outlined),
      ('المذاكرة', Icons.menu_book_rounded),
      ('الاختبار', Icons.quiz_outlined),
      ('مراجعة الأخطاء', Icons.fact_check_outlined),
      ('الإتقان', Icons.emoji_events_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.50),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == steps.length - 1 ? 0 : 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: i == steps.length - 1
                          ? colors.primary
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      steps[i].$2,
                      color: i == steps.length - 1
                          ? Colors.white
                          : colors.primary,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      steps[i].$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (i < steps.length - 1)
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: colors.outline,
                    )
                  else
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: colors.primary,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionPage extends StatefulWidget {
  const _SessionPage();

  @override
  State<_SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<_SessionPage> {
  static const totalSeconds = 25 * 60;

  int seconds = totalSeconds;
  bool running = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final minutes = seconds ~/ 60;
    final remainingSeconds =
        (seconds % 60).toString().padLeft(2, '0');

    final progress =
        (1 - (seconds / totalSeconds)).clamp(0.0, 1.0).toDouble();

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
              const SizedBox(height: 12),

              Text(
                running ? 'وقت التركيز' : 'جاهز للمذاكرة؟',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

              const SizedBox(height: 34),

              Container(
                width: 292,
                height: 292,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryContainer.withValues(
                    alpha: 0.35,
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor:
                            colors.outlineVariant.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$minutes:$remainingSeconds',
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'دقيقة تركيز',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
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
                          setState(() => running = true);
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
                      seconds = totalSeconds;
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
            'جلسة مذاكرة',
            25,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'انتهت الجلسة. حان وقت الراحة 5 دقائق.',
              ),
            ),
          );
        }
      },
    );
  }
}
