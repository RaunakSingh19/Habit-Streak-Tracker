import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_storage.dart';
import 'package:intl/intl.dart';

class HabitSwipeScreen extends StatefulWidget {
  const HabitSwipeScreen({super.key});

  @override
  State<HabitSwipeScreen> createState() => _HabitSwipeScreenState();
}

class _HabitSwipeScreenState extends State<HabitSwipeScreen> {
  List<Habit> _habits = [];
  int _cardIndex = 0;
  bool _finished = false;
  double _dragExtent = 0.0;

  // Palette of soft/neutral card colors
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
      _cardIndex = 0;
      _finished = false;
      _dragExtent = 0.0;
    });
  }

  Future<void> _markHabit(bool hit) async {
    if (_cardIndex >= _habits.length) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final habit = _habits[_cardIndex];
    habit.history[today] = hit;
    await HabitStorage.saveHabits(_habits);
    setState(() {
      _cardIndex += 1;
      _dragExtent = 0.0;
      if (_cardIndex >= _habits.length) {
        _finished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    if (_habits.isEmpty) {
      return const Center(child: Text("No habits added yet."));
    }

    if (_finished || _cardIndex >= _habits.length) {
      // Show a summary
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      int hitCount = _habits.where((h) => h.history[today] == true).length;
      int total = _habits.length;

      return Container(
        color: const Color(0xFFf5f6fa),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: isWide ? 64 : 48),
              const SizedBox(height: 18),
              Text(
                "Today's Habits Completed",
                style: TextStyle(fontSize: isWide ? 28 : 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "$hitCount / $total",
                style: TextStyle(
                  fontSize: isWide ? 36 : 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadHabits,
                icon: const Icon(Icons.refresh),
                label: const Text("Do Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 12),
                  textStyle: TextStyle(fontSize: isWide ? 20 : 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Card sizing: playing-card style, more vertical for mobile
    final cardWidth = size.width < 400 ? size.width * 0.92 : (isWide ? 420.0 : 340.0);
    final cardHeight = size.height < 700 ? (isWide ? 300.0 : 340.0) : (isWide ? 350.0 : 400.0);

    // Center the stack using a SizedBox and Center
    return Container(
      color: const Color(0xFFf5f6fa),
      child: Center(
        child: SizedBox(
          width: cardWidth + 40,
          height: cardHeight + 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = _habits.length - 1; i >= _cardIndex; i--)
                _buildStackedCard(
                  _habits[i],
                  i - _cardIndex,
                  i == _cardIndex,
                  cardWidth,
                  cardHeight,
                  isWide,
                  _cardColors[i % _cardColors.length],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedCard(Habit habit, int stackLevel, bool isTop, double cardWidth, double cardHeight, bool isWide, Color cardColor) {
    // Slight offset for stacked cards
    final stackOffset = 8.0 * stackLevel;

    if (!isTop) {
      return Positioned(
        top: stackOffset,
        left: stackOffset,
        child: _buildStaticHabitCard(habit, cardWidth, cardHeight, cardColor),
      );
    }
    // Top card: animated and swipeable
    return _buildAnimatedHabitCard(habit, cardWidth, cardHeight, cardColor);
  }

  Widget _buildAnimatedHabitCard(Habit habit, double cardWidth, double cardHeight, Color cardColor) {
    const dragThreshold = 100.0;

    // Fade in ✓ or ✗ as you swipe
    double rightAlpha = (_dragExtent / dragThreshold).clamp(0.0, 1.0);
    double leftAlpha = (-_dragExtent / dragThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.delta.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragExtent > dragThreshold) {
          // Swiped right: hit
          _markHabit(true);
        } else if (_dragExtent < -dragThreshold) {
          // Swiped left: miss
          _markHabit(false);
        } else {
          setState(() {
            _dragExtent = 0.0;
          });
        }
      },
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: cardColor,
          end: _dragExtent > 50
              ? const Color.fromARGB(255, 95, 236, 99)
              : _dragExtent < -50
                  ? const Color.fromARGB(255, 253, 93, 109)
                  : cardColor,
        ),
        duration: const Duration(milliseconds: 180),
        builder: (context, color, child) {
          return Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: Stack(
              children: [
                Card(
                  elevation: 14,
                  color: color,
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            habit.title,
                            style: TextStyle(
                              fontSize: cardWidth < 350 ? 22 : 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (habit.description.trim().isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              habit.description,
                              style: TextStyle(
                                fontSize: cardWidth < 350 ? 15 : 17,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
                // Swipe right icon
                Positioned(
                  left: 20,
                  top: cardHeight / 2 - 26,
                  child: Opacity(
                    opacity: rightAlpha,
                    child: Icon(Icons.check_circle, color: const Color.fromARGB(255, 39, 228, 45), size: 48),
                  ),
                ),
                // Swipe left icon
                Positioned(
                  right: 20,
                  top: cardHeight / 2 - 26,
                  child: Opacity(
                    opacity: leftAlpha,
                    child: Icon(Icons.cancel, color: const Color.fromARGB(255, 248, 40, 25), size: 48),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticHabitCard(Habit habit, double cardWidth, double cardHeight, Color cardColor) {
    return Card(
      elevation: 6,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Center(
          child: Text(
            habit.title,
            style: TextStyle(
              fontSize: cardWidth < 350 ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}