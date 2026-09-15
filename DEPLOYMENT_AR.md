# دليل النشر النهائي

## البنية

```text
smart_student_assistant/
├── lib/                       # Flutter
├── assets/                    # الشعار والموارد
├── web/                       # Flutter Web
├── backend/                   # Node.js AI Gateway
│   ├── server.js
│   ├── package.json
│   ├── Dockerfile
│   └── .env.example
├── .github/workflows/         # CI/CD
│   ├── flutter.yml
│   ├── backend.yml
│   └── release.yml
├── render.yaml                # إعداد نشر Docker
├── AI_SETUP_AR.md
└── DEPLOYMENT_AR.md
```

## ترتيب التنفيذ

1. أنشئ مستودع GitHub للمشروع.
2. انشر `backend` باستخدام Docker أو منصة استضافة تدعم Docker.
3. أضف `OPENAI_API_KEY` كمتغير سري في منصة الاستضافة.
4. تأكد أن `GET /health` يرجع `ok: true` و`providerConfigured: true`.
5. انسخ عنوان `/ai` إلى GitHub Actions Variable باسم `AI_ENDPOINT`.
6. شغّل Workflow `Smart Student Assistant — Flutter CI & APK`.
7. حمّل ملف APK من Artifacts، أو استخدم ناتج Web.

## iOS

بناء iOS يحتاج runner يعمل بنظام macOS. لا يتم بناء IPA من Ubuntu workflow الحالي. عند تجهيز حساب Apple وSigning يمكن إضافة workflow مستقل لـmacOS بدون تغيير Backend.
