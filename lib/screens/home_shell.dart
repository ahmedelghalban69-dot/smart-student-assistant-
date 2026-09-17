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

  static const pages = <Widget>[
    Dashboard(),
    PlanPage(),
    SubjectsPage(),
    AiPage(),
    ProfilePage(),
  ];

  static const labels = <String>[
    'الرئيسية',
    'الخطة',
    'المواد',
    'AI',
    'حسابي',
  ];

  static const icons = <IconData>[
    Icons.home_rounded,
    Icons.calendar_month_rounded,
    Icons.menu_book_rounded,
    Icons.auto_awesome_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        bottomNavigationBar: _BottomNavigation(
          currentIndex: index,
          labels: labels,
          icons: icons,
          onChanged: (value) {
            setState(() => index = value);
          },
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentIndex,
    required this.labels,
    required this.icons,
    required this.onChanged,
  });

  final int currentIndex;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 76,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: colors.primaryContainer,
          selectedIndex: currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: onChanged,
          destinations: [
            for (var i = 0; i < labels.length; i++)
              NavigationDestination(
                icon: Icon(
                  icons[i],
                  color: colors.onSurfaceVariant,
                ),
                selectedIcon: Icon(
                  icons[i],
                  color: colors.primary,
                ),
                label: labels[i],
              ),
          ],
        ),
      ),
    );
  }
}
