import 'package:flutter/material.dart' hide showTimePicker;
import 'package:abyss_frost/features/logs/widgets/sheet_widgets/time_picker/time_picker_container.dart';
import 'package:abyss_frost/core/widgets/custom_time_picker_from_flutter.dart';

class LogsTimePicker extends StatelessWidget {
  final ValueNotifier<TimeOfDay> timeFrom;
  final ValueNotifier<TimeOfDay> timeTo;
  final ValueChanged<TimeOfDay> changedFromTime;
  final ValueChanged<TimeOfDay> changedToTime;

  const LogsTimePicker({
    super.key,
    required this.timeFrom,
    required this.timeTo,
    required this.changedFromTime,
    required this.changedToTime,
  });

  Future<void> _pickFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      changedFromTime(picked);
    }
  }

  Future<void> _pickToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 23, minute: 59),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      changedToTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TimePickerContainer(
            timeNotifier: timeFrom,
            pick: _pickFromTime,
            onChanged: changedFromTime,
            text: "from",
          ),
          TimePickerContainer(
            timeNotifier: timeTo,
            pick: _pickToTime,
            onChanged: changedToTime,
            text: "to",
          ),
        ],
      ),
    );
  }
}