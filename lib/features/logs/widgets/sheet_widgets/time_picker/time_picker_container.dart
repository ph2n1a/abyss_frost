import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class TimePickerContainer extends StatelessWidget {
  final ValueNotifier<TimeOfDay> timeNotifier;
  final void Function(BuildContext) pick;
  final ValueChanged<TimeOfDay> onChanged;
  final String text;

  const TimePickerContainer({
    super.key,
    required this.timeNotifier,
    required this.onChanged,
    required this.pick,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      decoration: BoxDecoration(
        color: appColors.accentColor,
        borderRadius: BorderRadius.circular(50),
      ),
      margin: EdgeInsets.only(right: 15),
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            decoration: BoxDecoration(
              color: appColors.backColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                topLeft: Radius.circular(50),
                bottomRight: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: EdgeInsets.all(5),
            child: Icon(
              Icons.access_time,
              size: 30,
              color: appColors.accentColor,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
            child: Text(
              text,
              style: TextStyle(
                color: appColors.backColor,
                fontSize: 15,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(5),
              backgroundColor: appColors.backColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
            ),
            onPressed: () => pick(context),
            child: ValueListenableBuilder<TimeOfDay>(
              valueListenable: timeNotifier,
              builder: (context, time, child) {
                return Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: appColors.accentColor),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
