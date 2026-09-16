import 'package:flutter/material.dart';

import 'ai_page.dart';
import 'dashboard.dart';
import 'plan_page.dart';
import 'profile_page.dart';
import 'subjects_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final List<Widget> pages = const [
    Dashboard(),
    PlanPage(),
    SubjectsPage(),
    AiPage(),
    ProfilePage(),
  ];

  final List<String> labels = [
    'الرئيسية',
    'الخطة',
    'المواد',
    'AI',
    'حسابي',
  ];

  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.menu_book_rounded,
    Icons.auto_awesome_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: index,
            children: pages,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) {
            setState(() {
              index = value;
            });
          },
          destinations: [
            for (var i = 0; i < labels.length; i++)
              NavigationDestination(
                icon: Icon(icons[i]),
                label: labels[i],
              ),
          ],
        ),
      ),
    );
  }
}
