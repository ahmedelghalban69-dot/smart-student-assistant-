import 'package:flutter/material.dart';
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
        final s = AppState.instance;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            AppHeader(
              title: 'مساعد الطالب الذكي 👋',
              subtitle: 'خلّي مذاكرتك منظمة وأسهل كل يوم',
            ),
            const SizedBox(height: 18),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المستوى ${s.level}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${s.xp} XP'),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: s.learningProgress,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            SectionTitle('الوصول السريع'),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickAction(
                  icon: Icons.add,
                  title: 'إضافة مادة',
                  onTap: () => _addSubject(context),
                ),
                _QuickAction(
                  icon: Icons.task_alt,
                  title: 'إضافة مهمة',
                  onTap: () => _addTask(context),
                ),
                _QuickAction(
                  icon: Icons.timer,
                  title: 'جلسة مذاكرة',
                  onTap: () => _session(context),
                ),
                _QuickAction(
                  icon: Icons.quiz,
                  title: 'اختبار جديد',
                  onTap: () => _addExam(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SectionTitle('إحصائياتك'),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'المهام',
                    value:
                        '${s.completedTasks}/${s.tasks.length}',
                    icon: Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _MetricCard(
                    title: 'الدقائق',
                    value: '${s.totalMinutes}',
                    icon: Icons.schedule,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'الدروس',
                    value:
                        '${s.completedLessons}/${s.totalLessons}',
                    icon: Icons.menu_book,
                  ),
                ),
                Expanded(
                  child: _MetricCard(
                    title: 'متوسط الاختبارات',
                    value: '${s.averageExam.toStringAsFixed(0)}%',
                    icon: Icons.assessment,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SectionTitle('رحلتك الدراسية'),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.auto_awesome),
                ),
                title: const Text(
                  'المحتوى → الفهم → التلخيص → الاختبار → المراجعة',
                ),
                subtitle: const Text(
                  'استخدم أدوات الذكاء الاصطناعي لتحويل المحتوى إلى أدوات مذاكرة.',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addSubject(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة مادة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم المادة',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();

              if (value.isNotEmpty) {
                AppState.instance.addSubject(value);
              }

              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addTask(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة مهمة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم المهمة',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                AppState.instance.addTask(
                  controller.text.trim(),
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

  void _addExam(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يمكن إنشاء الاختبار من قسم الاختبارات.'),
      ),
    );
  }

  void _session(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _SessionPage(),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon),
      label: Text(title),
      onPressed: onTap,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(title),
          ],
        ),
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
  int seconds = 25 * 60;
  bool running = false;

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('جلسة مذاكرة'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${minutes.toString().padLeft(2, '0')}:'
              '${remaining.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 25),
            FilledButton(
              onPressed: _toggle,
              child: Text(running ? 'إيقاف' : 'ابدأ المذاكرة'),
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
      _run();
    }
  }

  Future<void> _run() async {
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
