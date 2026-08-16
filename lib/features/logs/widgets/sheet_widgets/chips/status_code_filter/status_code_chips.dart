import 'package:flutter/material.dart';
import 'package:abyss_frost/features/logs/widgets/sheet_widgets/chips/filter_chip.dart';

class StatusCodeChipsFilters extends StatelessWidget {
  final ValueNotifier<Map<String, bool>> statusFilters;

  const StatusCodeChipsFilters({
    super.key,
    required this.statusFilters,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: statusFilters,
      builder: (context, child) {
        return Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.start,
          spacing: 8,
          children: [
            MyFilterChip(
              label: "1xx",
              selected: statusFilters.value['1xx'] ?? false,
              onSelected: (value) {
                final newMap = Map<String, bool>.from(statusFilters.value);
                newMap['1xx'] = value;
                statusFilters.value = newMap;
              },
              avatarColor: Colors.lightGreen,
              avatarChild: const Icon(Icons.info_outline, color: Colors.lightGreen, size: 15),
            ),
            MyFilterChip(
              label: "2xx",
              selected: statusFilters.value['2xx'] ?? false,
              onSelected: (value) {
                final newMap = Map<String, bool>.from(statusFilters.value);
                newMap['2xx'] = value;
                statusFilters.value = newMap;
              },
              avatarColor: Colors.green,
              avatarChild: const Icon(Icons.check, color: Colors.green, size: 15),
            ),
            MyFilterChip(
              label: "3xx",
              selected: statusFilters.value['3xx'] ?? false,
              onSelected: (value) {
                final newMap = Map<String, bool>.from(statusFilters.value);
                newMap['3xx'] = value;
                statusFilters.value = newMap;
              },
              avatarColor: Colors.yellow,
              avatarChild: const Icon(Icons.network_ping_sharp, color: Colors.yellow, size: 15),
            ),
            MyFilterChip(
              label: "4xx",
              selected: statusFilters.value['4xx'] ?? false,
              onSelected: (value) {
                final newMap = Map<String, bool>.from(statusFilters.value);
                newMap['4xx'] = value;
                statusFilters.value = newMap;
              },
              avatarColor: Colors.purple,
              avatarChild: const Icon(Icons.block, color: Colors.purple, size: 15),
            ),
            MyFilterChip(
              label: "5xx",
              selected: statusFilters.value['5xx'] ?? false,
              onSelected: (value) {
                final newMap = Map<String, bool>.from(statusFilters.value);
                newMap['5xx'] = value;
                statusFilters.value = newMap;
              },
              avatarColor: Colors.blue,
              avatarChild: const Icon(Icons.clear, color: Colors.blue, size: 15),
            ),
            MyFilterChip(
              label: "Timeout",
              selected: statusFilters.value['Timeout'] ?? false,
              onSelected: (value) {
                final newMap = Map<String, bool>.from(statusFilters.value);
                newMap['Timeout'] = value;
                statusFilters.value = newMap;
              },
              avatarColor: Colors.red,
              avatarChild: const Icon(Icons.error_outline_sharp, color: Colors.red, size: 15),
            ),
          ],
        );
      },
    );
  }
}