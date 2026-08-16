import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class DaySelectorCard extends StatelessWidget {
  const DaySelectorCard({
    super.key,
    required this.selectedDate,
  });

  final ValueNotifier<DateTime> selectedDate;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: (day.weekday - 1) % 7));
  }

  DateTime _addDays(DateTime date, int days) => DateTime(
    date.year, date.month, date.day + days,
    date.hour, date.minute, date.second, date.millisecond,
  );

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isFutureDay(DateTime day) => day.isAfter(_today());

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return ValueListenableBuilder<DateTime>(
      valueListenable: selectedDate,
      builder: (context, date, _) {
        final start = _startOfWeek(date);
        final weekDays = List.generate(7, (i) => _addDays(start, i));

        // Можно ли листать в будущее (если открыта не текущая неделя)
        final canGoNext = start.isBefore(_startOfWeek(_today()));

        return Container(
          decoration: BoxDecoration(
            color: appColors.accentColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${_monthNames[date.month - 1]} ${date.year}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: appColors.backColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      backgroundColor: appColors.mediumColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        selectedDate.value = picked;
                      }
                    },
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: appColors.accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ArrowButton(
                    icon: Icons.arrow_back,
                    onTap: () => selectedDate.value = _addDays(date, -7),
                  ),
                  const SizedBox(width: 10),
                  _ArrowButton(
                    icon: Icons.arrow_forward,
                    onTap: canGoNext
                        ? () => selectedDate.value = _addDays(date, 7)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -100) {
                    if (canGoNext) {
                      selectedDate.value = _addDays(date, 7);
                    }
                  } else if (velocity > 100) {
                    selectedDate.value = _addDays(date, -7);
                  }
                },
                child: Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: _DayColumn(
                          label: _weekdayLabels[i],
                          date: weekDays[i],
                          isSelected: _isSameDay(weekDays[i], date),
                          isDisabled: _isFutureDay(weekDays[i]),
                          selectedColor: appColors.backColor,
                          onTap: () => selectedDate.value = weekDays[i],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.label,
    required this.date,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
    this.isDisabled = false,
  });

  final String label;
  final DateTime date;
  final bool isSelected;
  final bool isDisabled;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.35 : 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: appColors.mediumColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                date.day.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: appColors.mediumColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final enabled = onTap != null;

    return Material(
      color: appColors.mediumColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? appColors.accentColor : appColors.accentColor.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}