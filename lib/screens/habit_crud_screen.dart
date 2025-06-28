import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_storage.dart';
import 'package:uuid/uuid.dart';

class HabitCrudScreen extends StatefulWidget {
  const HabitCrudScreen({super.key});

  @override
  State<HabitCrudScreen> createState() => _HabitCrudScreenState();
}

class _HabitCrudScreenState extends State<HabitCrudScreen> {
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

  Future<void> _saveHabits() async {
    await HabitStorage.saveHabits(_habits);
  }

  void addHabit(String title, String description) {
    final habit = Habit(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdDate: DateTime.now(),
      history: {},
    );
    setState(() {
      _habits.add(habit);
    });
    _saveHabits();
  }

  void editHabit(String id, String newTitle, String newDesc) {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx != -1) {
      setState(() {
        _habits[idx] = Habit(
          id: _habits[idx].id,
          title: newTitle,
          description: newDesc,
          createdDate: _habits[idx].createdDate,
          history: _habits[idx].history,
        );
      });
      _saveHabits();
    }
  }

  void deleteHabit(String id) {
    setState(() {
      _habits.removeWhere((h) => h.id == id);
    });
    _saveHabits();
  }

  Future<void> _showAddOrEditDialog({Habit? habit}) async {
    final titleController = TextEditingController(text: habit?.title ?? "");
    final descController = TextEditingController(text: habit?.description ?? "");
    final isEdit = habit != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Habit" : "Add Habit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(isEdit ? "Save" : "Add"),
            onPressed: () {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isNotEmpty) {
                if (isEdit) {
                  editHabit(habit!.id, title, desc);
                } else {
                  addHabit(title, desc);
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
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
          "Manage Habits",
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueGrey),
                            tooltip: "Edit",
                            onPressed: () => _showAddOrEditDialog(habit: habit),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            tooltip: "Delete",
                            onPressed: () => deleteHabit(habit.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: "Add Habit",
      ),
    );
  }
}