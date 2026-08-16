import 'package:abyss_frost/features/statistics/widgets/base_statistic_block.dart';
import 'package:abyss_frost/features/statistics/widgets/choice_date_format.dart';
import 'package:abyss_frost/features/statistics/widgets/calendars/month_selector_card.dart'; // Импортируй новые
import 'package:abyss_frost/features/statistics/widgets/calendars/week_selector_card.dart'; // Импортируй новые
import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';
import 'package:abyss_frost/core/database/app_database.dart';
import 'widgets/calendars/day_selector_card.dart';
import 'widgets/statistics_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int formatSelectedIndex = 0; // 0: Day, 1: Week, 2: Month
  ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(DateTime.now());

  PeriodStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    selectedDate.addListener(_loadData);
  }

  @override
  void dispose() {
    selectedDate.removeListener(_loadData);
    selectedDate.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final db = await getDatabase();
      PeriodStats stats;

      if (formatSelectedIndex == 0) {
        stats = await db.getDayStatsGeneric(selectedDate.value);
      } else if (formatSelectedIndex == 1) {
        final day = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
        final weekStart = day.subtract(Duration(days: (day.weekday - 1) % 7));
        stats = await db.getWeekStats(weekStart);
      } else {
        stats = await db.getMonthStats(selectedDate.value);
      }

      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print('Error loading stats: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Stack(
      children: [
        ListView(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(13),
              child: _loading || _stats == null
                  ? const Center(child: CircularProgressIndicator())
                  : Wrap(
                spacing: 13,
                runSpacing: 13,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  BaseStatisticBlock(
                    label: "Average ping",
                    statisticInt: _stats!.avgPingMs.round(),
                    icon: Icons.timelapse_sharp,
                    statisticText: "ms",
                    additionalText: "${_stats!.totalPings} pings made",
                  ),
                  BaseStatisticBlock(
                    label: "Pings made",
                    statisticInt: _stats!.totalPings,
                    statisticText: "",
                    icon: Icons.network_ping_sharp,
                    additionalText: formatSelectedIndex == 0 ? "for today" : (formatSelectedIndex == 1 ? "for week" : "for month"),
                  ),
                  BaseStatisticBlock(
                    label: "The lowest ping",
                    statisticInt: _stats!.minPingMs ?? 0,
                    statisticText: "ms",
                    icon: Icons.trending_down_sharp,
                    additionalText: _getAdditionalTextForMinPing(_stats!.minPingMs),
                  ),
                  BaseStatisticBlock(
                    label: "The highest ping",
                    statisticInt: _stats!.maxPingMs ?? 0,
                    statisticText: "ms",
                    icon: Icons.trending_up_sharp,
                    additionalText: _getAdditionalTextForMaxPing(_stats!.maxPingMs),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: formatSelectedIndex == 0
                  ? DaySelectorCard(selectedDate: selectedDate)
                  : formatSelectedIndex == 1
                  ? WeekSelectorCard(selectedDate: selectedDate)
                  : MonthSelectorCard(selectedDate: selectedDate),
            ),
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: _loading || _stats == null
                  ? Container(
                height: 300,
                decoration: BoxDecoration(color: appColors.accentColor, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: CircularProgressIndicator()),
              )
                  : StatisticsChartWidget(
                stats: _stats!,
                cardColor: appColors.accentColor,
                textColor: appColors.backColor,
                mediumColor: appColors.mediumColor,
                backColor: appColors.backColor,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
        Positioned(
          child: Padding(
            padding: const EdgeInsets.only(top: 50, right: 13, left: 13, bottom: 20),
            child: Container(
              decoration: BoxDecoration(color: appColors.backColor, borderRadius: BorderRadius.circular(50)),
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text("Statistics", style: TextStyle(fontSize: 25, color: appColors.accentColor, fontWeight: FontWeight.w700)),
                  ),
                  ChoiceDateFormat(
                    formatIndex: formatSelectedIndex,
                    onChangedFormat: (value) {
                      setState(() => formatSelectedIndex = value);
                      _loadData();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getAdditionalTextForMinPing(int? minPing) {
    if (minPing == null) return "No data";
    if (minPing < 50) return "The internet works fine";
    if (minPing < 100) return "Good connection";
    return "Slow connection";
  }

  String _getAdditionalTextForMaxPing(int? maxPing) {
    if (maxPing == null) return "No data";
    if (maxPing > 500) return "very long...";
    if (maxPing > 200) return "slow connection";
    return "normal";
  }
}