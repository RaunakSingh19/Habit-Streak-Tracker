import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_storage.dart';
import 'package:intl/intl.dart';

class HabitSwipeScreen extends StatefulWidget {
  const HabitSwipeScreen({super.key});

  @override
  State<HabitSwipeScreen> createState() => _HabitSwipeScreenState();
}

class _HabitSwipeScreenState extends State<HabitSwipeScreen> with SingleTickerProviderStateMixin {
  List<Habit> _habits = [];
  int _cardIndex = 0;
  bool _finished = false;
  double _dragExtent = 0.0;
  bool? _swipeDirection; // true for right (done), false for left (miss)
  late AnimationController _controller;

  // Modern gradient card colors
  final List<List<Color>> _cardGradients = [
    [Color(0xFFB3FFFD), Color(0xFF1FA2FF)],
    [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
    [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
    [Color(0xFFFEE140), Color(0xFFFA709A)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFFFFA17F), Color(0xFF00223E)],
    [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
    [Color(0xFFFFE259), Color(0xFFFFA751)],
    [Color(0xFF86A8E7), Color(0xFF91EAC9)],
    [Color(0xFFF8FFAE), Color(0xFF43C6AC)],
  ];

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitStorage.loadHabits();
    setState(() {
      _habits = habits;
      _cardIndex = 0;
      _finished = false;
      _dragExtent = 0.0;
      _swipeDirection = null;
    });
    _controller.reset();
    _controller.forward();
  }

  Future<void> _markHabit(bool hit) async {
    if (_cardIndex >= _habits.length) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final habit = _habits[_cardIndex];
    habit.history[today] = hit;
    setState(() {
      _swipeDirection = null;
      _cardIndex += 1;
      _dragExtent = 0.0;
      if (_cardIndex >= _habits.length) {
        _finished = true;
      }
    });
    await HabitStorage.saveHabits(_habits);
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    if (_habits.isEmpty) {
      return Container(
        color: const Color(0xFFF0F4F8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: Colors.blueGrey, size: isWide ? 60 : 42),
              const SizedBox(height: 12),
              Text(
                "No habits added yet.",
                style: TextStyle(
                  fontSize: isWide ? 24 : 18,
                  color: Colors.blueGrey[700],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_finished || _cardIndex >= _habits.length) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      int hitCount = _habits.where((h) => h.history[today] == true).length;
      int total = _habits.length;

      return Container(
        color: const Color(0xFFF0F4F8),
        child: Center(
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isWide ? 32 : 22),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Container(
                width: isWide ? 400 : double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isWide ? 36 : 18, vertical: isWide ? 40 : 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF38F9D7), Color(0xFF43E97B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isWide ? 32 : 22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: isWide ? 64 : 52,
                        key: ValueKey(hitCount),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Well done!",
                      style: TextStyle(
                        fontSize: isWide ? 30 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                        letterSpacing: 0.07,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Today's Habits Completed",
                      style: TextStyle(
                        fontSize: isWide ? 22 : 16,
                        color: Colors.teal[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      style: TextStyle(
                        fontSize: isWide ? 36 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      child: Text("$hitCount / $total"),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: _loadHabits,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Do Again"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF118AB2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 12),
                        textStyle: TextStyle(fontSize: isWide ? 20 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: Colors.blueGrey.withOpacity(0.18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final cardWidth = size.width < 400 ? size.width * 0.94 : (isWide ? 420.0 : 340.0);
    final cardHeight = size.height < 700 ? (isWide ? 320.0 : 340.0) : (isWide ? 370.0 : 400.0);

    return Container(
      color: const Color(0xFFF0F4F8),
      child: Center(
        child: SizedBox(
          width: cardWidth + 40,
          height: cardHeight + 50,
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
                  _cardGradients[i % _cardGradients.length],
                ),
              if (_cardIndex < _habits.length)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.16, end: 0.37)
                        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_left, color: Colors.blueGrey[400], size: isWide ? 34 : 26),
                        const SizedBox(width: 8),
                        Text(
                          "Swipe left or right to mark",
                          style: TextStyle(
                            color: Colors.blueGrey[600],
                            fontSize: isWide ? 16 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.swipe_right, color: Colors.blueGrey[400], size: isWide ? 34 : 26),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedCard(Habit habit, int stackLevel, bool isTop, double cardWidth, double cardHeight, bool isWide, List<Color> cardGradient) {
    final stackOffset = 10.0 * stackLevel;

    if (!isTop) {
      return Positioned(
        top: stackOffset,
        left: stackOffset,
        child: _buildStaticHabitCard(habit, cardWidth, cardHeight, cardGradient, stackLevel),
      );
    }
    return _buildAnimatedHabitCard(habit, cardWidth, cardHeight, cardGradient, stackLevel);
  }

  Widget _buildAnimatedHabitCard(Habit habit, double cardWidth, double cardHeight, List<Color> cardGradient, int stackLevel) {
    const dragThreshold = 100.0;
    double rightAlpha = (_dragExtent / dragThreshold).clamp(0.0, 1.0);
    double leftAlpha = (-_dragExtent / dragThreshold).clamp(0.0, 1.0);

    // Color for swipe left/right
    Color? overlayColor;
    if (_dragExtent > 0) {
      overlayColor = Color.lerp(cardGradient[0], const Color.fromARGB(
          255, 45, 231, 50), rightAlpha);
    } else if (_dragExtent < 0) {
      overlayColor = Color.lerp(cardGradient[0], const Color.fromARGB(
          255, 243, 39, 62), leftAlpha);
    } else {
      overlayColor = cardGradient[0];
    }
    final blendedGradient = [
      overlayColor ?? cardGradient[0],
      cardGradient[1]
    ];

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.delta.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragExtent > dragThreshold) {
          _swipeDirection = true;
          _markHabit(true);
        } else if (_dragExtent < -dragThreshold) {
          _swipeDirection = false;
          _markHabit(false);
        } else {
          setState(() => _dragExtent = 0.0);
        }
      },
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: blendedGradient[0],
          end: overlayColor,
        ),
        duration: const Duration(milliseconds: 180),
        builder: (context, color, child) {
          return Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: Hero(
              tag: habit.title + "_card",
              child: Card(
                elevation: 16,
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: blendedGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            "Habit Card",
                            key: ValueKey(stackLevel),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: cardWidth < 350 ? 16 : 20,
                              color: Colors.blueGrey[700],
                              letterSpacing: 0.5,
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          habit.title,
                          style: TextStyle(
                            fontSize: cardWidth < 350 ? 23 : 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (habit.description.trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: 1.0,
                            child: Text(
                              habit.description,
                              style: TextStyle(
                                fontSize: cardWidth < 350 ? 14 : 17,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticHabitCard(Habit habit, double cardWidth, double cardHeight, List<Color> cardGradient, int stackLevel) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Habit Card",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: cardWidth < 350 ? 13 : 17,
                  color: Colors.blueGrey[600],
                  letterSpacing: 0.5,
                  fontFamily: 'RobotoMono',
                ),
              ),
              const SizedBox(height: 7),
              Text(
                habit.title,
                style: TextStyle(
                  fontSize: cardWidth < 350 ? 17 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}