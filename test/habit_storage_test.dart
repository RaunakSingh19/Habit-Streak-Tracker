import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_streak_tracker/data/habit_storage.dart';
import 'package:habit_streak_tracker/models/habit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('save and load habits', () async {
    SharedPreferences.setMockInitialValues({});

    final habit = Habit(
      id: "testid",
      title: "Drink water",
      description: "8 glasses",
      createdDate: DateTime.now(),
      history: {"2025-06-28": true},
    );

    await HabitStorage.saveHabits([habit]);

    final loaded = await HabitStorage.loadHabits();
    expect(loaded.length, 1);
    expect(loaded.first.title, "Drink water");
    expect(loaded.first.history["2025-06-28"], true);
  });
}
