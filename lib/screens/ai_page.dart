import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../services/app_state.dart';
import '../widgets/app_header.dart';
import 'flashcards_page.dart';
import 'quiz_page.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final TextEditingController prompt = TextEditingController();

  String result = '';
  bool loading = false;
  String mode = 'assistant';

  Future<void> ask(String text, String selectedMode) async {
    if (text.trim().isEmpty) {
      return;
    }

    setState(() {
      loading = true;
      result = '';
      mode = selectedMode;
    });

    try {
      result = await const AiService().generate(
        prompt:
            '${AppState.instance.buildStudyContext()}\n\n'
            'طلب المستخدم:\n$text',
        mode: selectedMode,
      );
    } catch (_) {
      result =
          'تعذر الوصول إلى خدمة الذكاء الاصطناعي. '
          'تحقق من الإنترنت وAI_ENDPOINT ثم حاول مرة أخرى.';
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Map<String, dynamic>>[
      {
        'label': 'فهم وشرح',
        'mode': 'explain',
        'icon': Icons.lightbulb,
      },
      {
        'label': 'تلخيص',
        'mode': 'summary',
        'icon': Icons.summarize,
      },
      {
        'label': 'اختبار',
        'mode': 'questions',
        'icon': Icons.quiz,
      },
      {
        'label': 'بطاقات مراجعة',
        'mode': 'flashcards',
        'icon': Icons.style,
      },
      {
        'label': 'خريطة ذهنية',
        'mode': 'mindmap',
        'icon': Icons.account_tree,
      },
      {
        'label': 'تصميم مذاكرة',
        'mode': 'design',
        'icon': Icons.palette,
      },
      {
        'label': 'مراجعة أخطاء',
        'mode': 'review',
        'icon': Icons.fact_check,
      },
      {
        'label': 'حل واجب',
        'mode': 'homework',
        'icon': Icons.calculate,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const AppHeader(
          title: 'المساعد الذكي',
          subtitle:
              'ذكاء اصطناعي مرتبط بموادك ودروسك وأخطاءك',
        ),
        const SizedBox(height: 18),
        TextField(
          controller: prompt,
          maxLines: 7,
          decoration: const InputDecoration(
            hintText:
                'الصق محتوى الدرس أو اكتب السؤال أو المطلوب...',
            prefixIcon: Icon(Icons.edit_note),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: loading
              ? null
              : () => ask(
                    prompt.text,
                    'assistant',
                  ),
          icon: const Icon(Icons.send),
          label: const Text('تنفيذ بالذكاء الاصطناعي'),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: actions.map((action) {
            final label = action['label'] as String;
            final actionMode = action['mode'] as String;
            final icon = action['icon'] as IconData;

            return ActionChip(
              avatar: Icon(
                icon,
                size: 18,
              ),
              label: Text(label),
              onPressed: loading
                  ? null
                  : () {
                      final text = prompt.text.trim().isEmpty
                          ? label
                          : prompt.text;

                      ask(
                        text,
                        actionMode,
                      );
                    },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuizPage(),
                  ),
                );
              },
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('ابدأ اختبارًا الآن'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FlashcardsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.style_outlined),
              label: const Text('ذاكر بالبطاقات'),
            ),
          ],
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        if (result.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 18),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'النتيجة • $mode',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(),
                  SelectableText(
                    result,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('سياق الدراسة متصل'),
            subtitle: Text(
              'يتم إرسال سياق المواد والدروس والمهام '
              'والأخطاء مع الطلب عند تفعيل Backend.',
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    prompt.dispose();
    super.dispose();
  }
}
