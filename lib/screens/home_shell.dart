import 'package:flutter/material.dart';

import 'ai_page.dart';
import 'dashboard.dart';
import 'plan_page.dart';
import 'profile_page.dart';
import 'subjects_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() =>
      _HomeShellState();
}

class _HomeShellState
    extends State<HomeShell> {
  int index = 0;

  static const pages = [
    Dashboard(),
    PlanPage(),
    SubjectsPage(),
    AiPage(),
    ProfilePage(),
  ];

  static const labels = [
    'الرئيسية',
    'الخطة',
    'المواد',
    'AI',
    'حسابي',
  ];

  static const icons = [
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.menu_book_rounded,
    Icons.auto_awesome_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: index,
            children: pages,
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(
                  color: colors.outlineVariant
                      .withValues(alpha: 0.45),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow
                      .withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              height: 72,
              elevation: 0,
              backgroundColor:
                  Colors.transparent,
              indicatorColor:
                  colors.primaryContainer,
              selectedIndex: index,
              onDestinationSelected:
                  (value) {
                setState(
                  () => index = value,
                );
              },
              labelBehavior:
                  NavigationDestinationLabelBehavior
                      .alwaysShow,
              destinations: [
                for (var i = 0;
                    i < labels.length;
                    i++)
                  NavigationDestination(
                    icon: Icon(icons[i]),
                    selectedIcon: Icon(
                      icons[i],
                      color: colors.primary,
                    ),
                    label: labels[i],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
