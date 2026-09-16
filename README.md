# Backend

خادم وسيط بسيط لتطبيق «مساعد الطالب الذكي». الهدف منه إبقاء مفاتيح مزود الذكاء الاصطناعي خارج تطبيق Flutter.

## التشغيل
```bash
cp .env.example .env
node server.js
```

## نقاط النهاية
- `GET /health` — فحص الحالة.
- `POST /ai` — يستقبل `{ "prompt": "...", "mode": "summary" }`.

إذا لم يتم ضبط `AI_PROVIDER_URL` يعيد الخادم رسالة اتصال تجريبية بدل استدعاء مزود خارجي. عند ضبطه، يرسل `prompt` و`mode` إلى المزود باستخدام `AI_PROVIDER_API_KEY`.
