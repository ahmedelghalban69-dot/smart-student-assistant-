# مساعد الطالب الذكي — Unified 2250.1

## تنفيذ هذه الدفعة
- مشروع Flutter موحد واحد بدل تكرار الإصدارات.
- المواد والدروس والمحتوى الذي تم أخذه.
- المهام والأولويات والمدة والتاريخ.
- خطة يومية وأسبوعية.
- مخطط ذكي بوقت متاح قابل للتعديل.
- جلسات متكررة أسبوعيًا.
- اختبار تفاعلي وحفظ محاولات الاختبار.
- بطاقات مراجعة تفاعلية.
- مراجعة الأخطاء.
- سياق دراسة متصل بخدمة AI.
- Backend منفصل لحماية مفتاح مزود الذكاء الاصطناعي.
- حفظ محلي للبيانات.
- دعم RTL والوضع الداكن/الفاتح.

## تحقق التنفيذ
تم فحص بنية الملفات، وتشغيل فحص Node syntax للـBackend. لم يتم تشغيل `flutter analyze` أو بناء APK/IPA/Web لأن Flutter SDK غير مثبت في بيئة التنفيذ الحالية.

## Build reliability pass

- GitHub Actions workflow now gates APK generation behind formatting, static analysis, unit/widget tests, and a Web release smoke test.
- Android platform files are generated during CI so the repository does not depend on machine-generated Android files being present in the ZIP.
- Java 17 is configured explicitly for the Android build environment.
- APK is uploaded as a GitHub Actions artifact.
