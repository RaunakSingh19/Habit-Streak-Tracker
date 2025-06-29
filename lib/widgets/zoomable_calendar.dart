import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/calendar_screen_detail.dart'; // Make sure this import is correct for your project structure

enum ZoomLevel {
  year,
  halfYear,
  quarterYear,
  month,
  week,
}

class ZoomableCalendarWithStick extends StatefulWidget {
  final Map<String, double> completionPerDay;
  final DateTime initialMonth;
  const ZoomableCalendarWithStick({
    super.key,
    required this.completionPerDay,
    required this.initialMonth,
  });

  @override
  State<ZoomableCalendarWithStick> createState() => _ZoomableCalendarWithStickState();
}

class _ZoomableCalendarWithStickState extends State<ZoomableCalendarWithStick> {
  ZoomLevel _zoomLevel = ZoomLevel.month;
  late DateTime _referenceDate;

  @override
  void initState() {
    super.initState();
    _referenceDate = widget.initialMonth;
  }

  void _onZoomChanged(double value) {
    setState(() {
      if (value == 0) {
        _zoomLevel = ZoomLevel.year;
      } else if (value == 0.25) {
        _zoomLevel = ZoomLevel.halfYear;
      } else if (value == 0.5) {
        _zoomLevel = ZoomLevel.quarterYear;
      } else if (value == 0.75) {
        _zoomLevel = ZoomLevel.month;
      } else if (value == 1.0) {
        _zoomLevel = ZoomLevel.week;
      }
    });
  }

  List<Map<String, dynamic>> _getVisibleGroups() {
    List<Map<String, dynamic>> groups = [];
    DateTime start;
    DateTime end;

    if (_zoomLevel == ZoomLevel.year) {
      start = DateTime(_referenceDate.year, 1, 1);
      end = DateTime(_referenceDate.year, 12, 31);
      for (int m = 1; m <= 12; m++) {
        final first = DateTime(_referenceDate.year, m, 1);
        final last = DateTime(_referenceDate.year, m + 1, 0);
        groups.add({"start": first, "end": last});
      }
    } else if (_zoomLevel == ZoomLevel.halfYear) {
      if (_referenceDate.month <= 6) {
        start = DateTime(_referenceDate.year, 1, 1);
        end = DateTime(_referenceDate.year, 6, 30);
        for (int m = 1; m <= 6; m++) {
          final first = DateTime(_referenceDate.year, m, 1);
          final last = DateTime(_referenceDate.year, m + 1, 0);
          groups.add({"start": first, "end": last});
        }
      } else {
        start = DateTime(_referenceDate.year, 7, 1);
        end = DateTime(_referenceDate.year, 12, 31);
        for (int m = 7; m <= 12; m++) {
          final first = DateTime(_referenceDate.year, m, 1);
          final last = DateTime(_referenceDate.year, m + 1, 0);
          groups.add({"start": first, "end": last});
        }
      }
    } else if (_zoomLevel == ZoomLevel.quarterYear) {
      int quarter = ((_referenceDate.month - 1) ~/ 3) + 1;
      int startMonth = (quarter - 1) * 3 + 1;
      start = DateTime(_referenceDate.year, startMonth, 1);
      end = DateTime(_referenceDate.year, startMonth + 3, 0);
      for (int m = startMonth; m < startMonth + 3; m++) {
        final first = DateTime(_referenceDate.year, m, 1);
        final last = DateTime(_referenceDate.year, m + 1, 0);
        groups.add({"start": first, "end": last});
      }
    } else if (_zoomLevel == ZoomLevel.month) {
      start = DateTime(_referenceDate.year, _referenceDate.month, 1);
      end = DateTime(_referenceDate.year, _referenceDate.month + 1, 0);
      for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        groups.add({"start": d, "end": d});
      }
    } else {
      int weekday = _referenceDate.weekday;
      start = _referenceDate.subtract(Duration(days: weekday - 1));
      end = start.add(const Duration(days: 6));
      for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        groups.add({"start": d, "end": d});
      }
    }
    return groups;
  }

  Color getColorForPercent(double percent) {
    // Modern gradient blue-green theme
    if (percent < 0.5) return const Color(0xFFEF476F); // pink-red
    if (percent < 0.6) return const Color(0xFFFFA36C); // orange
    if (percent < 0.7) return const Color(0xFFFFE066); // yellow
    if (percent < 0.8) return const Color(0xFF06D6A0); // teal-green
    if (percent < 0.9) return const Color(0xFF118AB2); // blue
    return const Color(0xFF073B4C); // dark blue/green
  }

  double _groupCompletion(Map<String, dynamic> group) {
    DateTime start = group["start"];
    DateTime end = group["end"];
    int total = 0;
    double sum = 0;
    for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      final dateStr = DateFormat('yyyy-MM-dd').format(d);
      if (widget.completionPerDay.containsKey(dateStr)) {
        sum += widget.completionPerDay[dateStr]!;
        total++;
      }
    }
    return total > 0 ? sum / total : 0.0;
  }

  Widget _buildZoomControls(BuildContext context, bool isMobile) {
    double sliderValue;
    switch (_zoomLevel) {
      case ZoomLevel.year:
        sliderValue = 0;
        break;
      case ZoomLevel.halfYear:
        sliderValue = 0.25;
        break;
      case ZoomLevel.quarterYear:
        sliderValue = 0.5;
        break;
      case ZoomLevel.month:
        sliderValue = 0.75;
        break;
      case ZoomLevel.week:
        sliderValue = 1.0;
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 8, vertical: isMobile ? 0 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMobile)
            Text(
              'Zoom Level',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF073B4C),
              ),
            ),
          if (!isMobile) const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: isMobile ? 24 : 20,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: isMobile ? 12 : 10),
              overlayShape: RoundSliderOverlayShape(overlayRadius: isMobile ? 18 : 16),
              activeTrackColor: const Color(0xFF06D6A0),
              inactiveTrackColor: const Color(0xFFBEE9E8),
              thumbColor: const Color(0xFF118AB2),
            ),
            child: Slider(
              min: 0,
              max: 1,
              divisions: 4,
              value: sliderValue,
              onChanged: (val) {
                double snapped = (val * 4).round() / 4.0;
                _onZoomChanged(snapped);
              },
              label: () {
                switch (_zoomLevel) {
                  case ZoomLevel.year:
                    return "Year";
                  case ZoomLevel.halfYear:
                    return "6 Months";
                  case ZoomLevel.quarterYear:
                    return "Quarter";
                  case ZoomLevel.month:
                    return "Month";
                  case ZoomLevel.week:
                    return "Week";
                }
              }(),
            ),
          ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Year', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF073B4C))),
                  Text('6M', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF073B4C))),
                  Text('Qtr', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF073B4C))),
                  Text('Month', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF073B4C))),
                  Text('Week', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF073B4C))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(Map<String, dynamic> group, bool isMobile, double cellHeight) {
    final start = group["start"] as DateTime;
    final end = group["end"] as DateTime;
    final percent = _groupCompletion(group);
    final hasData = percent > 0;

    String label;
    String subLabel = '';

    if (_zoomLevel == ZoomLevel.year ||
        _zoomLevel == ZoomLevel.halfYear ||
        _zoomLevel == ZoomLevel.quarterYear) {
      label = DateFormat('MMM').format(start);
      subLabel = '${DateFormat('d').format(start)}-${DateFormat('d').format(end)}';
    } else if (_zoomLevel == ZoomLevel.month) {
      label = DateFormat('E').format(start);
      subLabel = DateFormat('d').format(start);
    } else {
      label = DateFormat('E').format(start);
      subLabel = DateFormat('d').format(start);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.all(isMobile ? 2 : 4),
      height: cellHeight,
      constraints: BoxConstraints(
        minHeight: 40,
        maxHeight: cellHeight,
        minWidth: 40,
      ),
      decoration: BoxDecoration(
        color: hasData
            ? getColorForPercent(percent)
            : const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: hasData
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ]
            : null,
        border: hasData
            ? null
            : Border.all(color: const Color(0xFFE0E6ED)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CalendarDetailScreen(
                  startDate: start,
                  endDate: end,
                  completionPerDay: widget.completionPerDay,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 8, horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasData ? Colors.white : const Color(0xFF073B4C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasData
                          ? Colors.white.withOpacity(0.95)
                          : const Color(0xFF7B8794),
                    ),
                  ),
                  if (hasData &&
                      (_zoomLevel == ZoomLevel.month ||
                          _zoomLevel == ZoomLevel.week))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${(percent * 100).round()}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: const Color(0xFF073B4C))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getVisibleGroups();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isMobile = width < 600;

    int crossAxisCount = 7;
    double cellHeight =
    isMobile ? (height / 12).clamp(38, 58) : (height / 14).clamp(40, 72);

    if (_zoomLevel == ZoomLevel.year) {
      crossAxisCount = isMobile ? 4 : 12;
    } else if (_zoomLevel == ZoomLevel.halfYear) {
      crossAxisCount = isMobile ? 3 : 6;
    } else if (_zoomLevel == ZoomLevel.quarterYear) {
      crossAxisCount = isMobile ? 3 : 3;
    }

    final bgColor = const Color(0xFFE6F6F8);

    if (isMobile) {
      // Mobile layout - controls at bottom, grid fills available space
      return Container(
        color: bgColor,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: groups.length,
                  itemBuilder: (context, index) =>
                      _buildCalendarCell(groups[index], true, cellHeight),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: _buildZoomControls(context, true),
            ),
            // Legend at bottom for mobile
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFBEE9E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: [
                  _buildLegendItem(const Color(0xFFEF476F), '0-49%'),
                  _buildLegendItem(const Color(0xFFFFA36C), '50-59%'),
                  _buildLegendItem(const Color(0xFFFFE066), '60-69%'),
                  _buildLegendItem(const Color(0xFF06D6A0), '70-79%'),
                  _buildLegendItem(const Color(0xFF118AB2), '80-89%'),
                  _buildLegendItem(const Color(0xFF073B4C), '90-100%'),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      );
    } else {
      // Desktop/tablet layout - controls at top, legend at top right, grid is scrollable if needed
      return Container(
        color: bgColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zoom controls
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: _buildZoomControls(context, false),
                    ),
                  ),
                  // Legend
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 14),
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEE9E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 16,
                        children: [
                          _buildLegendItem(const Color(0xFFEF476F), '0-49%'),
                          _buildLegendItem(const Color(0xFFFFA36C), '50-59%'),
                          _buildLegendItem(const Color(0xFFFFE066), '60-69%'),
                          _buildLegendItem(const Color(0xFF06D6A0), '70-79%'),
                          _buildLegendItem(const Color(0xFF118AB2), '80-89%'),
                          _buildLegendItem(const Color(0xFF073B4C), '90-100%'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int gridCount = crossAxisCount;
                    double minCellWidth = 82;
                    if (constraints.maxWidth / gridCount < minCellWidth) {
                      gridCount = (constraints.maxWidth / minCellWidth)
                          .floor()
                          .clamp(2, crossAxisCount);
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        childAspectRatio: 1.10,
                      ),
                      itemCount: groups.length,
                      itemBuilder: (context, index) =>
                          _buildCalendarCell(groups[index], false, cellHeight),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}