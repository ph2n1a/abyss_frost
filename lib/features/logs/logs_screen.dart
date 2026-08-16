import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './widgets/ping_logs_list.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';
import 'package:abyss_frost/core/database/app_database.dart';
import '../../core/widgets/app_date_picker.dart';
import './widgets/bottom_sheet_content.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  DateTime _selectedDate = DateTime.now();
  final ValueNotifier<TimeOfDay> selectedTimeFrom = ValueNotifier<TimeOfDay>(
    const TimeOfDay(hour: 0, minute: 0),
  );
  final ValueNotifier<TimeOfDay> selectedTimeTo = ValueNotifier<TimeOfDay>(
    const TimeOfDay(hour: 23, minute: 59),
  );
  final ValueNotifier<Map<String, bool>> statusFilters =
      ValueNotifier<Map<String, bool>>({
        '1xx': false,
        '2xx': false,
        '3xx': false,
        '4xx': false,
        '5xx': false,
        'Timeout': false,
      });
  final ValueNotifier<RangeValues> latencyRange = ValueNotifier<RangeValues>(
    RangeValues(0, 999),
  );
  int latencyStart = 0;
  int latencyEnd = 999;
  final ValueNotifier<List<String>> targetUrls = ValueNotifier<List<String>>(
    [],
  );
  final ValueNotifier<Set<String>> selectedPingMethod = ValueNotifier<Set<String>>({});

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BottomSheetContent(
          timeFrom: selectedTimeFrom,
          timeTo: selectedTimeTo,
          changedFromTime: (value) {
            setState(() {
              selectedTimeFrom.value = value;
            });
          },
          changedToTime: (value) {
            setState(() {
              selectedTimeTo.value = value;
            });
          },
          statusFilters: statusFilters,
          initialLatencyRange: latencyRange.value,
          onLatencyClosed: (newRange) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  latencyRange.value = newRange;
                  latencyStart = newRange.start.round();
                  latencyEnd = newRange.end.round();
                });
              }
            });
          },
          selectedPingMethod: selectedPingMethod,
          targetUrls: targetUrls,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final db = Provider.of<AppDatabase>(context, listen: false);

    return Center(
      child: Stack(
        children: [
          StreamBuilder<List<PingLog>>(
            stream: db.getLogs(
              _selectedDate,
              timeFrom: selectedTimeFrom.value,
              timeTo: selectedTimeTo.value,
              statusFilters: statusFilters.value,
              latencyFrom: latencyStart,
              latencyTo: latencyEnd,
              pingMethods: selectedPingMethod.value.toList(),
              targetUrls: targetUrls.value,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final logs = snapshot.data ?? [];
              return PingLogsListView(logs: logs);
            },
          ),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 50,
                right: 13,
                left: 13,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: appColors.accentColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        height: 48,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Logs",
                              style: TextStyle(
                                fontSize: 25,
                                color: appColors.backColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: appColors.accentColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: appColors.backColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              onPressed: () {
                                _showBottomSheet(context);
                              },
                              icon: Icon(
                                Icons.filter_alt_sharp,
                                color: appColors.accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppDatePicker(
                    selectedDate: _selectedDate,
                    onChanged: (value) {
                      setState(() {
                        _selectedDate = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
