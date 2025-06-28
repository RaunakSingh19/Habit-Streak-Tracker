import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';

class HabitStorage {
  static const String habitsKey = "habit_list";

  // Load habits from local storage
  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString(habitsKey);
    if (habitsJson != null) {
      final decoded = json.decode(habitsJson) as List<dynamic>;
      return decoded.map((e) => Habit.fromJson(e)).toList();
    }
    return [];
  }

  // Save habits to local storage
  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(habits.map((e) => e.toJson()).toList());
    await prefs.setString(habitsKey, encoded);
  }
}