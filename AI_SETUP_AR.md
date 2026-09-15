# إعداد الذكاء الاصطناعي — مساعد الطالب الذكي

هذه النسخة تفصل بين التطبيق وخدمة الذكاء الاصطناعي:

**Flutter App → Backend HTTPS → OpenAI Responses API**

## 1) إعداد الخادم

انسخ `backend/.env.example` إلى ملف `.env` محلياً، ثم ضع مفتاح API في:

```text
OPENAI_API_KEY=...
```

ولا تضع المفتاح داخل Flutter أو GitHub أو أي ملف عام.

الإعداد الافتراضي للنموذج هو `gpt-5.6-luna`، ويمكن تغييره عبر `OPENAI_MODEL`.

## 2) تشغيل الخادم محلياً

```bash
cd backend
export OPENAI_API_KEY="ضع_المفتاح_هنا"
npm run check
npm start
```

اختبر:

```text
GET http://localhost:8787/health
```

## 3) نشر الخادم

المشروع يحتوي `Dockerfile` و`render.yaml` للنشر على خدمة تدعم Docker.
بعد النشر يجب أن يصبح لديك عنوان HTTPS مثل:

```text
https://YOUR-BACKEND.example.com
```

ونقطة الذكاء الاصطناعي:

```text
https://YOUR-BACKEND.example.com/ai
```

ضع `OPENAI_API_KEY` كـ Secret/Environment Variable في منصة النشر، وليس في المستودع.

## 4) ربط Flutter بالخادم

للبناء المحلي:

```bash
flutter pub get
flutter build apk --release \
  --dart-define=AI_ENDPOINT=https://YOUR-BACKEND.example.com/ai
```

وللويب:

```bash
flutter build web --release \
  --dart-define=AI_ENDPOINT=https://YOUR-BACKEND.example.com/ai
```

إذا لم تضبط `AI_ENDPOINT` فلن يستخدم التطبيق إجابات وهمية؛ سيعرض خطأ إعداد واضح.

## 5) GitHub Actions

في GitHub:

**Settings → Secrets and variables → Actions → Variables**

أضف متغيراً باسم:

```text
AI_ENDPOINT
```

وقيمته:

```text
https://YOUR-BACKEND.example.com/ai
```

لا تضف `OPENAI_API_KEY` إلى Flutter workflow. المفتاح يبقى في بيئة الـBackend فقط.

## 6) ما تم تأمينه

- مفتاح OpenAI لا يصل إلى تطبيق Flutter.
- Endpoint الـBackend هو نقطة الاتصال الوحيدة من التطبيق.
- تحديد معدل الطلبات.
- حد لحجم الطلب.
- مهلة للاتصال بمزود AI.
- رسائل أخطاء آمنة للمستخدم بدون تسريب تفاصيل المفتاح.
- `/health` لفحص حالة الخادم.
- فحص JavaScript تلقائياً في GitHub Actions.
- بناء Web وAndroid تلقائياً.

## 7) ملاحظة مهمة

لا تكتب مفتاح API داخل المحادثة، ولا تضعه في `pubspec.yaml` أو Dart أو Git. استخدم Secrets/Environment Variables في الخادم.
