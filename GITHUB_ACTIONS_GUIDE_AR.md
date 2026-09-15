# تشغيل بناء APK تلقائيًا عبر GitHub Actions

هذا المشروع يحتوي على Workflow يقوم بالتالي:

1. تنزيل المشروع.
2. تثبيت Flutter من قناة stable.
3. تنفيذ `flutter pub get`.
4. فحص تنسيق Dart.
5. تشغيل `flutter analyze`.
6. تشغيل `flutter test`.
7. بناء Web Release كاختبار إضافي.
8. إنشاء ملفات Android بواسطة `flutter create --platforms=android .` إذا لم تكن موجودة.
9. بناء APK Release بالأمر `flutter build apk --release`.
10. رفع `app-release.apk` كـ Artifact يمكن تنزيله من صفحة تشغيل الـWorkflow.

## الخطوات بالتفصيل

### 1) إنشاء حساب GitHub

ادخل إلى GitHub وأنشئ حسابًا إذا لم يكن لديك حساب.

### 2) إنشاء Repository جديد

- اختر **New repository**.
- الاسم المقترح: `smart-student-assistant`.
- اجعله Private إذا كنت لا تريد أن يكون كود المشروع عامًا.
- لا تضف README جديدًا؛ لأن المشروع يحتوي على README بالفعل.

### 3) رفع المشروع

بعد فك ZIP على الكمبيوتر، ارفع **محتويات مجلد المشروع نفسه** إلى المستودع.

يجب أن يظهر في جذر Repository مثلًا:

```text
pubspec.yaml
lib/
test/
assets/
web/
.github/
  workflows/
    flutter.yml
```

لا ترفع مجلدًا إضافيًا يحتوي المشروع بداخله؛ `pubspec.yaml` يجب أن يكون في جذر المستودع.

### 4) تشغيل البناء

بعد الرفع:

- افتح تبويب **Actions**.
- اختر **Smart Student Assistant CI + Android APK**.
- اضغط **Run workflow**.
- اختر فرع `main`.
- اضغط **Run workflow**.

### 5) ماذا يحدث؟

أول Job اسمه `Verify Flutter project`.

لن يتم بناء APK إذا فشل أي من:

- Dart formatting
- Flutter analyze
- Flutter tests
- Web release build

وهذا مقصود حتى لا يتم تسليم APK إذا كان المشروع يحتوي على مشكلة واضحة.

بعد نجاح التحقق يبدأ Job `Build release APK`.

### 6) تنزيل APK

بعد أن تصبح العملية خضراء:

- افتح الـWorkflow الناجح.
- انزل إلى قسم **Artifacts**.
- اختر الملف الذي ينتهي بـ `-apk`.
- نزّله وفك الضغط.
- ستجد داخله:

```text
app-release.apk
```

## ملاحظات مهمة

- الـAPK يتم بناؤه على خوادم GitHub، وليس على الهاتف.
- عدم وجود Flutter على جهازك لا يمنع GitHub Actions من البناء.
- مفتاح مزود الذكاء الاصطناعي **لا يجب وضعه داخل Flutter أو GitHub Repository**.
- Backend الذكاء الاصطناعي يجب أن يحتفظ بمفتاح المزود على الخادم فقط.
- الـWorkflow الحالي لا ينشئ توقيع متجر Google Play مخصصًا؛ الناتج Release APK مناسب للاختبار والتثبيت المباشر.
- قبل نشر التطبيق على Google Play نحتاج إعداد Android signing آمن باستخدام GitHub Secrets/Keystore.

## إذا فشل الـWorkflow

افتح:

**Actions → العملية الفاشلة → Job الفاشل → الخطوة الحمراء**

ثم انسخ رسالة الخطأ كاملة وأرسلها لي. لا تحذف الخطأ أو تختصره، لأن الرسالة تحدد الملف والمرحلة التي تحتاج إصلاحًا.
