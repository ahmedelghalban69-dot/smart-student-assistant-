# مساعد الطالب الذكي — Unified V2251

نسخة تنفيذية موحّدة تجمع المتطلبات والوظائف التي تم تطويرها عبر مراحل المشروع السابقة في مشروع Flutter واحد قابل للتوسعة.

## ما تم تنفيذه فعليًا
- Flutter + Material 3 + RTL عربي.
- Android / iOS / Web كأهداف بنية المشروع.
- إدارة المواد والدروس وتسجيل «ماذا أخذت في كل درس؟».
- مهام وواجبات مع أولوية ومدة تقديرية وتاريخ استحقاق.
- خطة يومية وأسبوعية.
- مولّد خطة ذكية محلي يعتمد على أولوية المهام ووقتها المتاح.
- جلسة مذاكرة 25 دقيقة مع تسجيل الجلسة وإظهار استراحة 5 دقائق.
- اختبارات قابلة للتنفيذ مع حساب النتيجة وتسجيل المحاولة والأخطاء.
- بطاقات مراجعة تفاعلية.
- سجل أخطاء ومراجعتها.
- XP ومستويات وإحصائيات تقدم.
- مساعد AI متعدد الأوضاع: شرح، تلخيص، أسئلة، بطاقات، خريطة ذهنية، تصميم مذاكرة، مراجعة أخطاء، حل واجب.
- ربط سياق المواد والدروس والمهام والأخطاء بطلبات AI.
- Backend Node.js آمن نسبيًا من جهة العميل: مفتاح مزود AI يبقى على الخادم، مع rate limiting وhealth endpoint وحد أقصى للطلب.
- حفظ محلي للحالة عبر SharedPreferences.
- شعار التطبيق داخل assets/branding/app_logo.png.

## تشغيل التطبيق
1. ثبّت Flutter SDK (Dart 3.3+).
2. شغّل `flutter pub get`.
3. شغّل `flutter run` لاختبار التطبيق.
4. للمنصات: `flutter create --platforms=android,ios,web .` ثم build للمنصة المطلوبة.

## تشغيل Backend
```bash
cd backend
node server.js
```
اضبط المتغيرات الموجودة في `.env.example`. التطبيق لا يحتاج لوضع مفتاح AI داخله.

## ملاحظة تحقق
تم تنفيذ وتجميع الملفات والـZIP في بيئة الإنشاء الحالية، لكن Flutter SDK غير مثبت في هذه البيئة، لذلك لم يتم الادعاء بأنه تم تشغيل `flutter analyze` أو بناء APK/IPA/Web هنا. يجب إجراء build على جهاز يحتوي على Flutter SDK.

## 🚀 Final AI + Deployment Setup

See `AI_SETUP_AR.md` for the complete AI configuration and `DEPLOYMENT_AR.md` for deployment.
The production architecture is **Flutter → HTTPS Backend → OpenAI Responses API**. API keys are backend-only.
