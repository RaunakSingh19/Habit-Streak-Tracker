import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'habit_swipe_screen.dart';
import 'habit_list_screen.dart';
import 'habit_crud_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CalendarScreen(),
    const HabitSwipeScreen(),
    const HabitListScreen(),
    const HabitCrudScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: "Calendar",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.swap_horiz),
      label: "Swipe",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.list_alt),
      label: "List",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: "Settings",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Modern, vibrant color palette
    const Color activeColor = Color(0xFF118AB2); // blue
    const Color inactiveColor = Color(0xFFBEE9E8); // light blue
    const Color backgroundColor = Color(0xFFE6F6F8); // pale blue background

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: activeColor.withOpacity(0.12),
          highlightColor: activeColor.withOpacity(0.07),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: backgroundColor,
            selectedItemColor: activeColor,
            unselectedItemColor: Color(0xFF7B8794),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              letterSpacing: 0.1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: _navItems,
          iconSize: 28,
          selectedFontSize: 14,
          unselectedFontSize: 13,
          elevation: 8,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        ),
      ),
    );
  }
}