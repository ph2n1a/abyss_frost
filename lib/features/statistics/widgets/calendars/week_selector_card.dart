import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class WeekSelectorCard extends StatefulWidget {
  final ValueNotifier<DateTime> selectedDate;
  const WeekSelectorCard({super.key, required this.selectedDate});

  @override
  State<WeekSelectorCard> createState() => _WeekSelectorCardState();
}

class _WeekSelectorCardState extends State<WeekSelectorCard> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(widget.selectedDate.value.year, widget.selectedDate.value.month, 1);
    widget.selectedDate.addListener(_updateMonth);
  }

  void _updateMonth() {
    final newMonth = DateTime(widget.selectedDate.value.year, widget.selectedDate.value.month, 1);
    if (mounted && _displayMonth != newMonth) {
      setState(() => _displayMonth = newMonth);
    }
  }

  @override
  void dispose() {
    widget.selectedDate.removeListener(_updateMonth);
    super.dispose();
  }

  List<List<DateTime>> _getWeeksInMonth() {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final lastDay = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final weeks = <List<DateTime>>[];
    DateTime current = firstDay.subtract(Duration(days: (firstDay.weekday - 1) % 7));

    while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
      final week = List.generate(7, (i) => current.add(Duration(days: i)));
      weeks.add(week);
      current = current.add(Duration(days: 7));
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final weeks = _getWeeksInMonth();
    final df = DateFormat('MMMM yyyy', 'en_US');
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final nextMonthStart = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    final firstDayOfNextCurrentMonth = DateTime(today.year, today.month + 1, 1);
    final canGoNext = nextMonthStart.isBefore(firstDayOfNextCurrentMonth);

    return Container(
      decoration: BoxDecoration(
        color: appColors.accentColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1)),
                icon: Icon(Icons.arrow_back, color: appColors.backColor),
              ),
              Expanded(
                child: Center(
                  child: Text(df.format(_displayMonth), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: appColors.backColor)),
                ),
              ),
              IconButton(
                onPressed: canGoNext
                    ? () => setState(() => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1))
                    : null,
                icon: Icon(
                  Icons.arrow_forward,
                  color: canGoNext ? appColors.backColor : appColors.backColor.withOpacity(0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weeks.length,
            itemBuilder: (context, index) {
              final week = weeks[index];
              final start = week.first;
              final end = week.last;

              final sel = widget.selectedDate.value;
              final selDay = DateTime(sel.year, sel.month, sel.day);
              final isSelected = !selDay.isBefore(start) && !selDay.isAfter(end);
              final isDisabled = start.isAfter(today);

              final startStr = DateFormat('d MMM', 'en_US').format(start);
              final endStr = DateFormat('d MMM', 'en_US').format(end);

              return GestureDetector(
                onTap: isDisabled ? null : () {
                  widget.selectedDate.value = start;
                },
                child: Opacity(
                  opacity: isDisabled ? 0.35 : 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? appColors.backColor : appColors.mediumColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Week ${index + 1}', style: TextStyle(color: isSelected ? appColors.mainColor : appColors.backColor, fontWeight: FontWeight.bold)),
                        Text('$startStr - $endStr', style: TextStyle(color: isSelected ? appColors.mainColor : appColors.backColor)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}