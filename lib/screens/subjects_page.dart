import 'package:flutter/material.dart';

import '../models/study_models.dart';
import '../services/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/section_title.dart';

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (_, __) {
        final state = AppState.instance;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const AppHeader(
              title: 'المواد والدروس',
              subtitle:
                  'سجّل ما أخذته في كل درس ليُبنى عليه الاختبار والمراجعة',
            ),
            const SizedBox(height: 18),
            SectionTitle(
              'موادك',
              action: 'إضافة',
              onTap: () => _addSubject(context),
            ),
            ...state.subjects.map(
              (subject) => Card(
                child: ExpansionTile(
                  title: Text(
                    subject.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '${subject.lessons.length} دروس • '
                    '${(subject.progress * 100).round()}% مكتمل',
                  ),
                  leading: CircularProgressIndicator(
                    value: subject.progress,
                  ),
                  children: [
                    ...subject.lessons.map(
                      (lesson) => CheckboxListTile(
                        value: lesson.studied,
                        onChanged: (_) =>
                            state.toggleLesson(subject, lesson),
                        title: Text(lesson.title),
                        subtitle: Text(
                          lesson.learnedContent.isEmpty
                              ? 'لم تسجل ما أخذته بعد'
                              : lesson.learnedContent,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondary: IconButton(
                          icon: const Icon(Icons.edit_note),
                          onPressed: () => _edit(context, lesson),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline),
                      title: const Text('إضافة درس'),
                      onTap: () => _addLesson(context, subject),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('حذف المادة'),
                      onTap: () {
                        state.deleteSubject(subject);
                      },
                    ),
                  ],
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();

              if (name.isNotEmpty) {
                AppState.instance.addSubject(name);
              }

              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addLesson(BuildContext context, Subject subject) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة درس'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم الدرس',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();

              if (title.isNotEmpty) {
                AppState.instance.addLesson(subject, title);
              }

              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _edit(BuildContext context, Lesson lesson) {
    final controller = TextEditingController(
      text: lesson.learnedContent,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'ماذا أخذت في ${lesson.title}؟',
        ),
        content: TextField(
          controller: controller,
          maxLines: 7,
          decoration: const InputDecoration(
            hintText: 'اكتب القواعد والأفكار والنقاط المهمة',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              AppState.instance.updateLessonContent(
                lesson,
                controller.text.trim(),
              );

              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
