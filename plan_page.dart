import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../models/study_models.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});
  @override State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  DateTime day = DateTime.now();
  int tab = 0;
  int dailyMinutes = 120;

  String fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> addSchedule() async {
    final title = TextEditingController();
    final subject = TextEditingController();
    final minutes = TextEditingController(text: '25');
    final recurring = ValueNotifier<bool>(false);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة جلسة للخطة'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'المهمة أو الجلسة')),
          TextField(controller: subject, decoration: const InputDecoration(labelText: 'المادة')),
          TextField(controller: minutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المدة بالدقائق')),
          ValueListenableBuilder<bool>(valueListenable: recurring, builder: (_, v, __) => SwitchListTile(title: const Text('تكرار أسبوعي'), value: v, onChanged: (x) => recurring.value = x)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إضافة')),
        ],
      ),
    );
    final m = int.tryParse(minutes.text) ?? 25;
    if (ok == true && title.text.trim().isNotEmpty) {
      final count = AppState.instance.scheduleFor(day).length;
      AppState.instance.addSchedule(title.text.trim(), subject.text.trim().isEmpty ? 'عام' : subject.text.trim(), DateTime(day.year, day.month, day.day, 16 + count, 0), m.clamp(15, 180).toInt(), recurring: recurring.value);
      setState(() {});
    }
    title.dispose(); subject.dispose(); minutes.dispose(); recurring.dispose();
  }

  @override Widget build(BuildContext c) {
    final state = AppState.instance;
    final items = tab == 0 ? state.scheduleFor(day) : state.weekFor(day);
    final tasks = state.tasksFor(day);
    return ListView(padding: const EdgeInsets.all(18), children: [
      Row(children: [
        IconButton(onPressed: () => setState(() => day = day.subtract(const Duration(days: 1))), icon: const Icon(Icons.chevron_right)),
        Expanded(child: Text('الخطة • ${fmt(day)}', textAlign: TextAlign.center, style: Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
        IconButton(onPressed: () => setState(() => day = day.add(const Duration(days: 1))), icon: const Icon(Icons.chevron_left)),
      ]),
      const SizedBox(height: 10),
      SegmentedButton<int>(segments: const [
        ButtonSegment(value: 0, label: Text('اليوم'), icon: Icon(Icons.today)),
        ButtonSegment(value: 1, label: Text('الأسبوع'), icon: Icon(Icons.view_week)),
      ], selected: {tab}, onSelectionChanged: (v) => setState(() => tab = v.first)),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.auto_awesome), const SizedBox(width: 10), Expanded(child: Text('المخطط الذكي يوزع المهام غير المكتملة حسب الأولوية والوقت المتاح.'))]),
        const SizedBox(height: 8),
        Row(children: [const Text('الوقت المتاح:'), Expanded(child: Slider(value: dailyMinutes.toDouble(), min: 30, max: 360, divisions: 11, label: '$dailyMinutes دقيقة', onChanged: (v) => setState(() => dailyMinutes = v.round()))), Text('$dailyMinutes د')]),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () { state.generateSmartPlan(day, dailyMinutes: dailyMinutes); setState(() {}); }, icon: const Icon(Icons.auto_fix_high), label: const Text('إنشاء الخطة الذكية'))),
      ]))),
      if (state.lastPlannerMessage.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(state.lastPlannerMessage)),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: addSchedule, icon: const Icon(Icons.add), label: const Text('إضافة جلسة')),
      const SizedBox(height: 14),
      if (tab == 0 && tasks.isNotEmpty) ...[
        const Text('مهام اليوم', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 6),
        ...tasks.map((t) => Card(child: CheckboxListTile(value: t.completed, onChanged: (_) { state.toggleTask(t); setState(() {}); }, title: Text(t.title), subtitle: Text('${t.subject} • أولوية ${t.priority} • ${t.estimatedMinutes} دقيقة')))),
        const SizedBox(height: 8),
      ],
      if (items.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('لا توجد جلسات مخططة.')))),
      ...items.map((x) => Card(child: ListTile(
        leading: CircleAvatar(child: Text('${x.start.hour.toString().padLeft(2, '0')}')),
        title: Text(x.title, style: TextStyle(decoration: x.completed ? TextDecoration.lineThrough : null)),
        subtitle: Text('${x.subject} • ${x.minutes} دقيقة${x.recurring ? ' • أسبوعي' : ''}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Checkbox(value: x.completed, onChanged: (_) { state.toggleSchedule(x); setState(() {}); }),
          IconButton(onPressed: () { state.deleteSchedule(x); setState(() {}); }, icon: const Icon(Icons.delete_outline)),
        ]),
      ))),
    ]);
  }
}
