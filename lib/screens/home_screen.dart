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

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const CalendarScreen();
      case 1:
        return const HabitSwipeScreen();
      case 2:
        return const HabitListScreen();
      case 3:
        return const HabitCrudScreen();
      default:
        return const CalendarScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE VERTICAL MENU
            Container(
              width: 60,
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: "Calendar View",
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => setState(() => _selectedIndex = 0),
                  ),
                  IconButton(
                    tooltip: "Swipe Habits",
                    icon: const Icon(Icons.swipe),
                    onPressed: () => setState(() => _selectedIndex = 1),
                  ),
                  IconButton(
                    tooltip: "All Habits List",
                    icon: const Icon(Icons.list),
                    onPressed: () => setState(() => _selectedIndex = 2),
                  ),
                  IconButton(
                    tooltip: "Manage Habits (CRUD)",
                    icon: const Icon(Icons.settings),
                    onPressed: () => setState(() => _selectedIndex = 3),
                  ),
                ],
              ),
            ),

            // RIGHT SIDE CONTENT AREA
            Expanded(
              child: Container(
                color: Colors.white,
                child: _getScreen(_selectedIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }
}