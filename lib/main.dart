import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_shell.dart';
import 'services/app_state.dart';
Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await AppState.instance.init(); runApp(const SmartStudentAssistantApp()); }
class SmartStudentAssistantApp extends StatelessWidget { const SmartStudentAssistantApp({super.key}); @override Widget build(BuildContext c){final s=AppState.instance; return AnimatedBuilder(animation:s,builder:(_,__)=>MaterialApp(debugShowCheckedModeBanner:false,title:'مساعد الطالب الذكي',theme:AppTheme.light(),darkTheme:AppTheme.dark(),themeMode:s.themeMode=='light'?ThemeMode.light:s.themeMode=='dark'?ThemeMode.dark:ThemeMode.system,home:const HomeShell()));} }
