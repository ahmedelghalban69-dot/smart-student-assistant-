import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../widgets/app_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              title: 'حسابي والإحصائيات',
              subtitle: 'تقدمك، إنجازاتك، إعداداتك',
            ),
            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.55,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _stat('المستوى', '${state.level}'),
                _stat('XP', '${state.xp}'),
                _stat('وقت المذاكرة', '${state.totalMinutes} د'),
                _stat(
                  'المهام',
                  '${state.completedTasks}/${state.tasks.length}',
                ),
                _stat(
                  'تقدم التعلم',
                  '${(state.learningProgress * 100).round()}%',
                ),
                _stat(
                  'متوسط الاختبارات',
                  '${state.averageExam.round()}%',
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'مراجعة الأخطاء',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...state.reviews.map(
              (review) => Card(
                child: ListTile(
                  title: Text(review.topic),
                  subtitle: Text(
                    '${review.subject} • ${review.errors} أخطاء',
                  ),
                  trailing: review.reviewed
                      ? const Icon(Icons.check_circle)
                      : FilledButton(
                          onPressed: () => state.review(review),
                          child: const Text('راجعت'),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'المظهر',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioGroup<String>(
              groupValue: state.themeMode,
              onChanged: (value) {
                if (value != null) {
                  state.setTheme(value);
                }
              },
              child: const Column(
                children: [
                  RadioListTile<String>(
                    title: Text('حسب الجهاز'),
                    value: 'system',
                  ),
                  RadioListTile<String>(
                    title: Text('فاتح'),
                    value: 'light',
                  ),
                  RadioListTile<String>(
                    title: Text('داكن'),
                    value: 'dark',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Card(
              child: ListTile(
                leading: Icon(Icons.cloud_done),
                title: Text('متصل بالإنترنت'),
                subtitle: Text(
                  'التطبيق يعتمد على Backend للذكاء الاصطناعي ويمكن توسيعه للمزامنة السحابية.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.security),
                title: Text('الأمان'),
                subtitle: Text(
                  'مفتاح مزود الذكاء الاصطناعي لا يوضع داخل تطبيق Flutter؛ يحتفظ به الخادم.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.devices),
                title: Text('الإصدارات المستهدفة'),
                subtitle: Text(
                  'Android • iOS • Web، مع بنية قابلة لإضافة منصات أخرى.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('الإصدار'),
                subtitle: Text(
                  'Unified V2250.0.0 — consolidated implementation',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stat(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}
