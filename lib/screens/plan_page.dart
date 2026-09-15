import 'package:flutter/material.dart';
import '../models/study_models.dart';
import '../services/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/section_title.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  DateTime selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (_, __) {
        final s = AppState.instance;
        final day = DateTime(
          selected.year,
          selected.month,
          selected.day,
        );

        final schedule = s.schedule.where((x) {
          final d = DateTime(
            x.date.year,
            x.date.month,
            x.date.day,
          );
          return d == day;
        }).toList();

        final tasks = s.tasks.where((x) {
          final d = DateTime(
            x.dueDate.year,
            x.dueDate.month,
            x.dueDate.day,
          );
          return d == day;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const AppHeader(
              title: 'خطتي الدراسية',
              subtitle: 'نظّم يومك ووزّع وقت المذاكرة بذكاء',
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selected =
                              selected.subtract(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${selected.day}/${selected.month}/${selected.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selected =
                              selected.add(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SectionTitle(
              'جلسات المذاكرة',
              action: 'إضافة',
              onTap: () => _addSchedule(context),
            ),
            if (schedule.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('لا توجد جلسات مذاكرة لهذا اليوم.'),
                ),
              )
            else
              ...schedule.map(
                (item) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.menu_book),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      '${item.startTime} - ${item.endTime}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        s.deleteSchedule(item);
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            SectionTitle('مهام اليوم'),
            if (tasks.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('لا توجد مهام لهذا اليوم.'),
                ),
              )
            else
              ...tasks.map(
                (task) => Card(
                  child: CheckboxListTile(
                    value: task.completed,
                    onChanged: (_) => s.toggleTask(task),
                    title: Text(task.title),
                    subtitle: Text(task.priority),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _startStudy(context),
              icon: const Icon(Icons.timer),
              label: const Text('ابدأ جلسة مذاكرة 25 دقيقة'),
            ),
          ],
        );
      },
    );
  }

  void _addSchedule(BuildContext context) {
    final title = TextEditingController();
    final start = TextEditingController(text: '16:00');
    final end = TextEditingController(text: '16:25');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة جلسة مذاكرة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(
                labelText: 'اسم الجلسة',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: start,
              decoration: const InputDecoration(
                labelText: 'وقت البداية',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: end,
              decoration: const InputDecoration(
                labelText: 'وقت النهاية',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isNotEmpty) {
                AppState.instance.addSchedule(
                  ScheduleItem(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    title: title.text.trim(),
                    date: selected,
                    startTime: start.text.trim(),
                    endTime: end.text.trim(),
                  ),
                );
              }

              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _startStudy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _PlanTimerPage(),
      ),
    );
  }
}

class _PlanTimerPage extends StatefulWidget {
  const _PlanTimerPage();

  @override
  State<_PlanTimerPage> createState() => _PlanTimerPageState();
}

class _PlanTimerPageState extends State<_PlanTimerPage> {
  int seconds = 25 * 60;
  bool running = false;

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('جلسة المذاكرة'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${minutes.toString().padLeft(2, '0')}:'
              '${remaining.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(
                running ? Icons.pause : Icons.play_arrow,
              ),
              label: Text(
                running ? 'إيقاف مؤقت' : 'ابدأ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      running = !running;
    });

    if (running) {
      _tick();
    }
  }

  Future<void> _tick() async {
    while (mounted && running && seconds > 0) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted || !running) {
        return;
      }

      setState(() {
        seconds--;
      });
    }

    if (mounted && seconds == 0) {
      setState(() {
        running = false;
      });

      AppState.instance.addSession(
        StudySession(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          startedAt: DateTime.now(),
          durationMinutes: 25,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'انتهت الجلسة 🎉 حان وقت الراحة 5 دقائق.',
          ),
        ),
      );
    }
  }
}
