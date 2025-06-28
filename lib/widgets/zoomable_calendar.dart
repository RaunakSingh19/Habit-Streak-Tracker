import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ZoomLevel {
  year,
  halfYear,
  quarterYear,
  month,
  week,
}

class ZoomableCalendarWithStick extends StatefulWidget {
  final Map<String, double> completionPerDay; // e.g., {"2025-06-01": 0.7}
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

  // For year/half/quarter, group by month and show month name and date range
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
      // week
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
    if (percent < 0.5) return Colors.red;
    if (percent < 0.6) return Colors.yellow.shade200;
    if (percent < 0.7) return Colors.yellow.shade400;
    if (percent < 0.8) return Colors.orange;
    if (percent < 0.9) return Colors.lightGreen;
    return Colors.green;
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

  Widget _buildZoomStick(bool isMobile) {
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

    return RotatedBox(
      quarterTurns: -1,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: isMobile ? 30 : 24,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: isMobile ? 16 : 12),
          overlayShape: RoundSliderOverlayShape(overlayRadius: isMobile ? 22 : 18),
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
                return "1 Year";
              case ZoomLevel.halfYear:
                return "6 Months";
              case ZoomLevel.quarterYear:
                return "3 Months";
              case ZoomLevel.month:
                return "1 Month";
              case ZoomLevel.week:
                return "1 Week";
            }
          }(),
        ),
      ),
    );
  }

  Widget _zoomLabels(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RotatedBox(quarterTurns: -1, child: Text('1 Year', style: TextStyle(fontSize: isMobile ? 14 : 12))),
        RotatedBox(quarterTurns: -1, child: Text('6 Months', style: TextStyle(fontSize: isMobile ? 14 : 12))),
        RotatedBox(quarterTurns: -1, child: Text('3 Months', style: TextStyle(fontSize: isMobile ? 14 : 12))),
        RotatedBox(quarterTurns: -1, child: Text('1 Month', style: TextStyle(fontSize: isMobile ? 14 : 12))),
        RotatedBox(quarterTurns: -1, child: Text('1 Week', style: TextStyle(fontSize: isMobile ? 14 : 12))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getVisibleGroups();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 500;

    // Layout: Horizontal grid on desktop/tablet, vertical grid on mobile
    int crossAxisCount;
    double cellFont = isMobile ? 18 : 14;
    double cellHeight = isMobile ? 60 : 36;
    double cellWidth = isMobile ? size.width * 0.8 : 80;

    if (_zoomLevel == ZoomLevel.year) {
      crossAxisCount = isMobile ? 1 : 12;
    } else if (_zoomLevel == ZoomLevel.halfYear) {
      crossAxisCount = isMobile ? 1 : 6;
    } else if (_zoomLevel == ZoomLevel.quarterYear) {
      crossAxisCount = isMobile ? 1 : 3;
    } else {
      crossAxisCount = 7;
    }

    return Row(
      children: [
        SizedBox(
          width: isMobile ? 50 : 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildZoomStick(isMobile),
              const SizedBox(height: 12),
              _zoomLabels(isMobile),
            ],
          ),
        ),
        Expanded(
          child: isMobile
              // VERTICAL LAYOUT FOR MOBILE: Use ListView with big cells
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: groups.length,
                  itemBuilder: (context, idx) {
                    final group = groups[idx];
                    final start = group["start"] as DateTime;
                    final end = group["end"] as DateTime;
                    final percent = _groupCompletion(group);

                    String label;
                    if (_zoomLevel == ZoomLevel.year ||
                        _zoomLevel == ZoomLevel.halfYear ||
                        _zoomLevel == ZoomLevel.quarterYear) {
                      label =
                          "${DateFormat('MMM').format(start)}\n${DateFormat('d').format(start)} - ${DateFormat('d').format(end)}";
                    } else if (_zoomLevel == ZoomLevel.month) {
                      label =
                          "${DateFormat('E').format(start)}\n${DateFormat('d').format(start)}";
                    } else {
                      // week view
                      label =
                          "${DateFormat('E').format(start)}\n${DateFormat('d').format(start)}";
                    }

                    return Container(
                      width: cellWidth,
                      height: cellHeight,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: percent > 0
                            ? getColorForPercent(percent)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: cellFont, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                )
              // HORIZONTAL GRID FOR DESKTOP/TABLET
              : GridView.builder(
                  itemCount: groups.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.8,
                  ),
                  itemBuilder: (context, idx) {
                    final group = groups[idx];
                    final start = group["start"] as DateTime;
                    final end = group["end"] as DateTime;
                    final percent = _groupCompletion(group);

                    String label;
                    if (_zoomLevel == ZoomLevel.year ||
                        _zoomLevel == ZoomLevel.halfYear ||
                        _zoomLevel == ZoomLevel.quarterYear) {
                      label =
                          "${DateFormat('MMM').format(start)}\n${DateFormat('d').format(start)} - ${DateFormat('d').format(end)}";
                    } else if (_zoomLevel == ZoomLevel.month) {
                      label =
                          "${DateFormat('E').format(start)}\n${DateFormat('d').format(start)}";
                    } else {
                      // week view
                      label =
                          "${DateFormat('E').format(start)}\n${DateFormat('d').format(start)}";
                    }

                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: percent > 0
                            ? getColorForPercent(percent)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: cellFont),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}