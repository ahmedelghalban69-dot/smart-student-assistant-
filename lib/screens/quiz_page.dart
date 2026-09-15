import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../models/study_models.dart';

class QuizPage extends StatefulWidget {
  final String subject;
  const QuizPage({super.key, this.subject = 'الرياضيات'});
  @override State<QuizPage> createState() => _QuizPageState();
}
class _QuizPageState extends State<QuizPage> {
  late List<QuizQuestion> questions;
  int index = 0;
  int correct = 0;
  int? selected;
  bool answered = false;
  @override void initState() { super.initState(); questions = _buildQuestions(widget.subject); }
  List<QuizQuestion> _buildQuestions(String subject) => [
    QuizQuestion(id:'q1', text:'ما أفضل طريقة للتعامل مع درس جديد؟', options:['حفظ كل شيء دون فهم','فهم الفكرة ثم التدريب عليها','تأجيله دائمًا','قراءة العنوان فقط'], correctIndex:1, explanation:'الفهم ثم التطبيق والتكرار يبني تعلمًا أقوى.'),
    QuizQuestion(id:'q2', text:'ماذا نفعل بعد اكتشاف خطأ في اختبار؟', options:['نتجاهله','نحذف الاختبار','نسجل الخطأ ونراجعه','نتوقف عن المذاكرة'], correctIndex:2, explanation:'مراجعة الأخطاء تحول الاختبار إلى أداة تعلم.'),
    QuizQuestion(id:'q3', text:'أي عنصر يساعد على خطة مذاكرة واقعية؟', options:['وقت متاح محدد','مهام بلا مدة','خطة بلا مواعيد','تجاهل الاختبارات'], correctIndex:0, explanation:'تحديد الوقت المتاح يسمح بتوزيع المهام بشكل عملي.'),
    QuizQuestion(id:'q4', text:'ما وظيفة بطاقات المراجعة؟', options:['عرض الإعلانات','التدريب على الاسترجاع السريع','حذف الدروس','إيقاف المؤقت'], correctIndex:1, explanation:'البطاقات تدرب على استدعاء المعلومة من الذاكرة.'),
    QuizQuestion(id:'q5', text:'متى تكون جلسة المذاكرة أكثر قابلية للإنجاز؟', options:['عندما تكون محددة بمدة ومهمة','عندما تكون مفتوحة بلا هدف','عندما تتجاهل الراحة','عندما تجمع كل المواد معًا'], correctIndex:0, explanation:'الجلسة المحددة بهدف ومدة تقلل التشتت.'),
  ];
  void choose(int i) { if (answered) return; setState(() { selected=i; answered=true; if (i==questions[index].correctIndex) correct++; }); }
  void next() { if (!answered) return; if (index+1 >= questions.length) { AppState.instance.addQuizAttempt('اختبار ${widget.subject}', widget.subject, correct, questions.length); showDialog(context:context, builder:(_)=>AlertDialog(title:const Text('انتهى الاختبار 🎉'),content:Text('نتيجتك: $correct / ${questions.length} (${((correct/questions.length)*100).round()}%)'),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('إغلاق'))])); return; } setState(() { index++; selected=null; answered=false; }); }
  @override Widget build(BuildContext context) { final q=questions[index]; return Scaffold(appBar:AppBar(title:Text('اختبار ${widget.subject}')),body:Directionality(textDirection:TextDirection.rtl,child:ListView(padding:const EdgeInsets.all(18),children:[LinearProgressIndicator(value:(index+1)/questions.length),const SizedBox(height:20),Text('السؤال ${index+1} من ${questions.length}',style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(18),child:Text(q.text,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800,height:1.5)))),const SizedBox(height:12),...List.generate(q.options.length,(i){final isCorrect=i==q.correctIndex; final isSelected=i==selected; return Card(child:ListTile(onTap:()=>choose(i),leading:Icon(answered && isCorrect?Icons.check_circle:answered&&isSelected?Icons.cancel_outlined:Icons.radio_button_unchecked),title:Text(q.options[i]),subtitle:answered&&isSelected?Text(isCorrect?'إجابة صحيحة':'إجابة غير صحيحة'):null));}),if(answered)Card(color:Theme.of(context).colorScheme.surfaceContainerHighest,child:Padding(padding:const EdgeInsets.all(14),child:Text(q.explanation,style:const TextStyle(height:1.5)))),const SizedBox(height:16),FilledButton(onPressed:answered?next:null,child:Text(index+1==questions.length?'إنهاء الاختبار':'السؤال التالي'))])); }
                                                                                           }
