import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDetailScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, double> completionPerDay;

  const CalendarDetailScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.completionPerDay,
  });

  @override
  Widget build(BuildContext context) {
    List<DateTime> days = [];
    for (DateTime d = startDate;
    !d.isAfter(endDate);
    d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${DateFormat('MMM d, yyyy').format(startDate)}"
              " - ${DateFormat('MMM d, yyyy').format(endDate)}",
        ),
        backgroundColor: const Color(0xFF118AB2),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, idx) {
          final day = days[idx];
          final key = DateFormat('yyyy-MM-dd').format(day);
          final percent = completionPerDay[key];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: percent != null
                  ? _getColorForPercent(percent)
                  : Colors.grey[300],
              child: Text(
                DateFormat('d').format(day),
                style: TextStyle(
                  color: percent != null ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(DateFormat('EEEE, MMM d, yyyy').format(day)),
            subtitle: percent != null
                ? Text("Completion: ${(percent * 100).toStringAsFixed(0)}%")
                : const Text("No data"),
          );
        },
      ),
    );
  }

  Color _getColorForPercent(double percent) {
    if (percent < 0.5) return const Color(0xFFEF476F); // pink-red
    if (percent < 0.6) return const Color(0xFFFFA36C); // orange
    if (percent < 0.7) return const Color(0xFFFFE066); // yellow
    if (percent < 0.8) return const Color(0xFF06D6A0); // teal-green
    if (percent < 0.9) return const Color(0xFF118AB2); // blue
    return const Color(0xFF073B4C); // dark blue/green
  }
}