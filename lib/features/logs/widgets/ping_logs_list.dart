import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class PingLogsListView extends StatelessWidget {
  final List<PingLog> logs;

  const PingLogsListView({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'There are no ping records for this day.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(appColors.mediumColor),
        radius: const Radius.circular(4.0),
      ),
      child: Scrollbar(
        interactive: true,
        child: ListView.builder(
          itemCount: logs.length + 2,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SizedBox(height: 105);
            }
            if (index == logs.length + 1) {
              return const SizedBox(height: 70);
            }

            final log = logs[index - 1];

            return PingLogCard(log: log, appColors: appColors);
          },
        ),
      ),
    );
  }
}

class PingLogCard extends StatefulWidget {
  final PingLog log;
  final AppColors appColors;

  const PingLogCard({
    super.key,
    required this.log,
    required this.appColors,
  });

  @override
  State<PingLogCard> createState() => _PingLogCardState();
}

class _PingLogCardState extends State<PingLogCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final appColors = widget.appColors;

    Color statusColor;
    final code = log.statusCode;

    switch (code) {
      case null:
        statusColor = Colors.red;
      case >= 100 && < 200:
        statusColor = Colors.lightGreen;
      case >= 200 && < 300:
        statusColor = Colors.green;
      case >= 300 && < 400:
        statusColor = Colors.yellow;
      case >= 400 && < 500:
        statusColor = Colors.purple;
      case >= 500 && < 600:
        statusColor = Colors.blue;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.2),
                child: Icon(
                  switch (log.statusCode) {
                    null => Icons.error_outline_sharp,
                    int code when code >= 100 && code <= 299 => Icons.check,
                    int code when code >= 300 && code <= 399 => Icons.network_ping_sharp,
                    429 => Icons.timer_outlined,
                    int code when code >= 400 && code <= 499 => Icons.block,
                    int code when code >= 500 && code <= 599 => Icons.dns_outlined,
                    int() => Icons.help_outline,
                  },
                  color: statusColor,
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      log.targetUrl,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${log.dataTime.hour.toString().padLeft(2, '0')}:${log.dataTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        log.statusCode != null ? 'Code: ${log.statusCode}' : 'Code: no answer',
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${log.latencyMs} ms',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        switch (log.pingMethod) {
                          'Via Proxy GET' => 'via GET',
                          'Via Proxy HEAD' => 'via HEAD',
                          _ => log.pingMethod,
                        },
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: appColors.backColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AnimatedCrossFade(
              firstChild: SizedBox(height: 0, width: double.infinity),
              secondChild: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appColors.accentColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Text(
                        log.networkDetails ?? 'No additional details available for this ping.',
                        style: TextStyle(fontSize: 13, color: appColors.accentColor),
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}