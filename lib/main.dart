import 'package:flutter/material.dart';
import 'screens/home_shell.dart';
import 'services/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.load();

  runApp(
    SmartStudentAssistantApp(
      appState: appState,
    ),
  );
}

class SmartStudentAssistantApp extends StatelessWidget {
  final AppState appState;

  const SmartStudentAssistantApp({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مساعد الطالب الذكي',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomeShell(appState: appState),
    );
  }
}
