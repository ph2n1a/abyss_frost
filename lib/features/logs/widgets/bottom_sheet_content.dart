import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';
import 'sheet_widgets/time_picker/logs_time_picker.dart';
import 'sheet_widgets/chips/status_code_filter/status_code_chips.dart';
import 'sheet_widgets/latency/latency_block.dart';
import 'sheet_widgets/ping_method/segmented_button_method.dart';
import 'sheet_widgets/chips/targets_url_filter/url_chips.dart';

class BottomSheetContent extends StatefulWidget {
  final ValueNotifier<TimeOfDay> timeFrom;
  final ValueNotifier<TimeOfDay> timeTo;
  final ValueChanged<TimeOfDay> changedFromTime;
  final ValueChanged<TimeOfDay> changedToTime;
  final ValueNotifier<Map<String, bool>> statusFilters;
  final RangeValues initialLatencyRange;
  final ValueChanged<RangeValues> onLatencyClosed;
  final ValueNotifier<Set<String>> selectedPingMethod;
  final ValueNotifier<List<String>> targetUrls;

  const BottomSheetContent({
    super.key,
    required this.timeFrom,
    required this.timeTo,
    required this.changedFromTime,
    required this.changedToTime,
    required this.statusFilters,
    required this.initialLatencyRange,
    required this.onLatencyClosed,
    required this.selectedPingMethod,
    required this.targetUrls,
  });

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late ValueNotifier<RangeValues> _localLatencyRange;

  @override
  void initState() {
    super.initState();
    _localLatencyRange = ValueNotifier(widget.initialLatencyRange);
  }

  @override
  void dispose() {
    widget.onLatencyClosed(_localLatencyRange.value);
    _localLatencyRange.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 10,
        right: 10,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.mainColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
            ),
            const Center(
              child: Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            LogsTimePicker(
              timeFrom: widget.timeFrom,
              timeTo: widget.timeTo,
              changedFromTime: widget.changedFromTime,
              changedToTime: widget.changedToTime,
            ),
            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 35,
                  ),
                  child: Text(
                    "Status codes",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                )
              ],
            ),
            StatusCodeChipsFilters(
              statusFilters: widget.statusFilters,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 35,
                  ),
                  child: Text(
                    "Ping latency",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                )
              ],
            ),
            LatencyBlock(
              latencyRange: _localLatencyRange,
              latencyRangeChange: (value) {
                _localLatencyRange.value = value;
              },
            ),
            const Divider(),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 35,
                  ),
                  child: Text(
                    "URL filters",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                )
              ],
            ),

            UrlFiltersChips(
              targetUrls: widget.targetUrls,
            ),
            const Divider(),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 35,
                  ),
                  child: Text(
                    "Protocol filter",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                )
              ],
            ),
            SegmentButtonPingMethodFilter(
              selectedMethods: widget.selectedPingMethod,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}