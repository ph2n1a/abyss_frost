import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AppDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const AppDatePicker({
    super.key,
    required this.selectedDate,
    required this.onChanged,
  });

  bool get _canGoNext {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return selectedDate.isBefore(todayOnly);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: 180,
      height: 48,
      decoration: BoxDecoration(
        color: appColors.accentColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appColors.backColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  onChanged(
                    selectedDate.subtract(const Duration(days: 1)),
                  );
                },
                icon: Icon(
                  Icons.keyboard_arrow_left_outlined,
                  size: 25,
                  color: appColors.accentColor,
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: appColors.backColor,
              fixedSize: const Size(80, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
            child: Center(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: appColors.accentColor,
                    ),
                  ),
                  Text(
                    DateFormat('dd.MM').format(selectedDate),
                    style: TextStyle(
                      color: appColors.accentColor
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appColors.backColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: IconButton(
                onPressed: _canGoNext
                    ? () {
                  onChanged(
                    selectedDate.add(const Duration(days: 1)),
                  );
                }
                    : null,
                icon: Icon(
                  Icons.keyboard_arrow_right_outlined,
                  size: 25,
                  color: appColors.accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
