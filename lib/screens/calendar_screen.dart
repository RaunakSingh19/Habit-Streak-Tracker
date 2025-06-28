import 'package:flutter/material.dart';
import 'package:habit_streak_tracker/widgets/zoomable_calendar.dart';
// import '../widgets/zoomable_calendar_with_stick.dart';
import '../data/habit_storage.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<String, double> _completionPerDay = {};

  @override
  void initState() {
    super.initState();
    _calculateCompletion();
  }

  Future<void> _calculateCompletion() async {
    final habits = await HabitStorage.loadHabits();
    final Map<String, List<bool>> hitMap = {};
    for (final habit in habits) {
      habit.history.forEach((date, hit) {
        hitMap.putIfAbsent(date, () => []);
        hitMap[date]!.add(hit);
      });
    }
    final Map<String, double> completionPercent = {};
    hitMap.forEach((date, list) {
      if (list.isNotEmpty) {
        completionPercent[date] = list.where((x) => x).length / list.length;
      }
    });
    setState(() {
      _completionPerDay = completionPercent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Streak Tracker"),
      ),
      body: ZoomableCalendarWithStick(
        completionPerDay: _completionPerDay,
        initialMonth: DateTime.now(),
      ),
    );
  }
}