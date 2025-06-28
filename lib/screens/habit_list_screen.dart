import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_storage.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({Key? key}) : super(key: key);

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  List<Habit> _habits = [];

  final List<Color> _cardColors = [
    Color(0xFFe3f2fd), // blue[50]
    Color(0xFFfce4ec), // pink[50]
    Color(0xFFe8f5e9), // green[50]
    Color(0xFFf3e5f5), // purple[50]
    Color(0xFFfffde7), // yellow[50]
    Color(0xFFf9fbe7), // lime[50]
    Color(0xFFede7f6), // deepPurple[50]
    Color(0xFFfbe9e7), // deepOrange[50]
    Color(0xFFf1f8e9), // lightGreen[50]
    Color(0xFFeceff1), // blueGrey[50]
  ];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitStorage.loadHabits();
    setState(() {
      _habits = habits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f6fa),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "All Habits",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _habits.isEmpty
          ? const Center(
              child: Text(
                "No habits found.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                final cardColor = _cardColors[index % _cardColors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Card(
                    color: cardColor,
                    elevation: 3,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          habit.title.isNotEmpty ? habit.title[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54),
                        ),
                      ),
                      title: Text(
                        habit.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: habit.description.trim().isNotEmpty
                          ? Text(
                              habit.description,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            )
                          : null,
                      onTap: () {
                        // optional: open detail screen
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}