import 'package:abyss_frost/core/database/app_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide showTimePicker;
import 'package:intl/intl.dart';
import 'package:abyss_frost/core/widgets/custom_time_picker_from_flutter.dart';

class StatisticsChartWidget extends StatefulWidget {
  const StatisticsChartWidget({
    super.key,
    required this.stats,
    required this.cardColor,
    required this.textColor,
    required this.mediumColor,
    required this.backColor,
  });

  final PeriodStats stats;
  final Color cardColor;
  final Color textColor;
  final Color mediumColor;
  final Color backColor;

  @override
  State<StatisticsChartWidget> createState() => _StatisticsChartWidgetState();
}

class _StatisticsChartWidgetState extends State<StatisticsChartWidget> {
  double _minX = 0;
  double _maxX = 24;
  double _lastPinchSpan = 1;
  Offset _lastPinchFocalPoint = Offset.zero;
  double _dragStartMinX = 0;
  double _dragStartRange = 24;
  Offset _dragStartLocalPosition = Offset.zero;
  double _chartWidth = 300;
  bool _isPinching = false;
  bool _isDragging = false;
  final GlobalKey _chartKey = GlobalKey();
  final Map<int, Offset> _activePointers = <int, Offset>{};
  static const double _leftTitlesReservedSize = 52.0;
  static const double _minStablePinchSpan = 24.0;

  double get _periodStart => 0.0;
  double get _periodEnd {
    if (widget.stats.period == StatsPeriod.day) return 24.0;
    if (widget.stats.period == StatsPeriod.week) return 7.0;
    return widget.stats.endDate.day.toDouble();
  }

  double get _maxRange => _periodEnd;

  double get _minRange {
    if (widget.stats.period == StatsPeriod.day) return 0.25;
    if (widget.stats.period == StatsPeriod.week) return 0.5;
    return 1.0;
  }

  @override
  void initState() {
    super.initState();
    _maxX = _periodEnd;
  }

  @override
  void didUpdateWidget(covariant StatisticsChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats != widget.stats) {
      _resetZoom();
    }
  }

  void _resetZoom() {
    setState(() {
      _activePointers.clear();
      _isPinching = false;
      _isDragging = false;
      _minX = _periodStart;
      _maxX = _periodEnd;
    });
  }

  void _updateChartWidth() {
    final box = _chartKey.currentContext?.findRenderObject() as RenderBox?;
    _chartWidth = box?.size.width ?? _chartWidth;
  }

  double get _plotWidth {
    final chartWidth = _chartWidth <= 1 ? 1.0 : _chartWidth;
    return (chartWidth - _leftTitlesReservedSize).clamp(1.0, chartWidth);
  }

  double _plotFractionFromLocalDx(double localDx) {
    final fraction = (localDx - _leftTitlesReservedSize) / _plotWidth;
    return fraction.clamp(0.0, 1.0);
  }

  double _hoursAtLocalDx(
    double localDx, {
    required double minX,
    required double range,
  }) {
    return minX + _plotFractionFromLocalDx(localDx) * range;
  }

  void _applyVisibleRange(double minX, double maxX) {
    final range = (maxX - minX).clamp(_minRange, _maxRange);
    var nextMinX = minX;
    var nextMaxX = minX + range;

    if (nextMinX < _periodStart) {
      nextMinX = _periodStart;
      nextMaxX = _periodStart + range;
    }
    if (nextMaxX > _periodEnd) {
      nextMaxX = _periodEnd;
      nextMinX = _periodEnd - range;
    }

    _minX = nextMinX;
    _maxX = nextMaxX;
  }

  List<Offset>? _firstTwoPointerPositions() {
    if (_activePointers.length < 2) return null;
    return _activePointers.values.take(2).toList(growable: false);
  }

  double _pinchSpan(Offset a, Offset b) => (a - b).distance;

  void _startPinch() {
    final points = _firstTwoPointerPositions();
    if (points == null) return;
    _updateChartWidth();
    _lastPinchFocalPoint = (points[0] + points[1]) / 2;
    _lastPinchSpan = _pinchSpan(
      points[0],
      points[1],
    ).clamp(_minStablePinchSpan, double.infinity);
    _isDragging = false;
    _isPinching = true;
  }

  void _updatePinch() {
    final points = _firstTwoPointerPositions();
    if (points == null) return;
    if (!_isPinching) _startPinch();

    final currentRange = _maxX - _minX;
    final lastFocalXHours = _hoursAtLocalDx(
      _lastPinchFocalPoint.dx,
      minX: _minX,
      range: currentRange,
    );
    final currentFocalPoint = (points[0] + points[1]) / 2;
    final currentSpan = _pinchSpan(
      points[0],
      points[1],
    ).clamp(_minStablePinchSpan, double.infinity);
    final scale = currentSpan / _lastPinchSpan;
    if (!scale.isFinite || scale <= 0) return;

    final newRange = (currentRange / scale).clamp(_minRange, _maxRange);
    final currentFocalFraction = _plotFractionFromLocalDx(currentFocalPoint.dx);
    final newMinX = lastFocalXHours - currentFocalFraction * newRange;

    setState(() {
      _applyVisibleRange(newMinX, newMinX + newRange);
      _lastPinchFocalPoint = currentFocalPoint;
      _lastPinchSpan = currentSpan;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    if (_activePointers.length == 2) setState(_startPinch);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_activePointers.containsKey(event.pointer)) return;
    _activePointers[event.pointer] = event.localPosition;
    if (_activePointers.length >= 2) _updatePinch();
  }

  void _onPointerEnd(PointerEvent event) {
    final wasPinching = _isPinching;
    _activePointers.remove(event.pointer);

    if (!wasPinching) return;

    if (_activePointers.length >= 2) {
      _startPinch();
      return;
    }

    setState(() {
      _isPinching = false;
      if (_activePointers.length == 1) {
        _isDragging = true;
        _dragStartMinX = _minX;
        _dragStartRange = _maxX - _minX;
        _dragStartLocalPosition = _activePointers.values.first;
        _updateChartWidth();
      }
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_activePointers.length > 1) return;
    _updateChartWidth();
    _dragStartMinX = _minX;
    _dragStartRange = _maxX - _minX;
    _dragStartLocalPosition = details.localPosition;
    setState(() => _isDragging = true);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_activePointers.length > 1 || _isPinching) return;
    final deltaX = details.localPosition.dx - _dragStartLocalPosition.dx;
    final deltaHours = -deltaX * _dragStartRange / _plotWidth;
    setState(() {
      _applyVisibleRange(
        _dragStartMinX + deltaHours,
        _dragStartMinX + deltaHours + _dragStartRange,
      );
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    setState(() => _isDragging = false);
  }

  void _onHorizontalDragCancel() {
    if (!_isDragging) return;
    setState(() => _isDragging = false);
  }

  TimeOfDay _timeOfDayFromHourValue(
    double value, {
    required bool allowEndOfDay,
  }) {
    final maxMinutes = allowEndOfDay ? 24 * 60 : 24 * 60 - 1;
    final totalMinutes = (value * 60).round().clamp(0, maxMinutes);
    final normalizedMinutes = totalMinutes == 24 * 60 ? 0 : totalMinutes;
    return TimeOfDay(
      hour: normalizedMinutes ~/ 60,
      minute: normalizedMinutes % 60,
    );
  }

  Future<void> _pickFromTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDayFromHourValue(_minX, allowEndOfDay: false),
      builder: (ctx, child) => _themedPicker(ctx, child),
    );
    if (picked != null) {
      final newX = picked.hour + picked.minute / 60.0;
      if (newX < _maxX) {
        setState(() => _minX = newX);
      }
    }
  }

  Future<void> _pickToTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDayFromHourValue(_maxX, allowEndOfDay: true),
      builder: (ctx, child) => _themedPicker(ctx, child),
    );
    if (picked != null) {
      double newX = picked.hour + picked.minute / 60.0;
      if (newX == 0) newX = 24;
      if (newX > _minX) {
        setState(() => _maxX = newX);
      }
    }
  }

  Widget _themedPicker(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: widget.backColor,
          surface: widget.cardColor,
          onSurface: widget.textColor,
        ),
      ),
      child: child!,
    );
  }

  List<FlSpot> _convertToSpots() {
    return widget.stats.logs.where((log) => log.latencyMs != null).map((log) {
      double x;
      if (widget.stats.period == StatsPeriod.day) {
        x = log.dataTime.hour + log.dataTime.minute / 60.0;
      } else if (widget.stats.period == StatsPeriod.week) {
        x = (log.dataTime.weekday - 1) + log.dataTime.hour / 24.0;
      } else {
        x = (log.dataTime.day - 1) + log.dataTime.hour / 24.0;
      }
      return FlSpot(x, log.latencyMs!.toDouble());
    }).toList()..sort((a, b) => a.x.compareTo(b.x));
  }

  List<List<FlSpot>> _splitIntoSegments(
    List<FlSpot> spots, {
    double gapHours = 0.5,
  }) {
    if (spots.isEmpty) return [];
    final segments = <List<FlSpot>>[];
    List<FlSpot> current = [spots.first];

    double gap = widget.stats.period == StatsPeriod.day ? gapHours : 12.0;

    for (var i = 1; i < spots.length; i++) {
      if (spots[i].x - spots[i - 1].x > gap) {
        segments.add(current);
        current = [spots[i]];
      } else {
        current.add(spots[i]);
      }
    }
    if (current.isNotEmpty) segments.add(current);
    return segments;
  }

  List<LineChartBarData> _buildBars() {
    final spots = _convertToSpots();
    if (spots.isEmpty) return [];
    return _splitIntoSegments(spots)
        .map(
          (seg) => LineChartBarData(
            spots: seg,
            isCurved: true,
            color: widget.backColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, _, _, _) =>
                  FlDotCirclePainter(radius: 3, color: widget.backColor),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: widget.backColor.withValues(alpha: 0.1),
            ),
          ),
        )
        .toList();
  }

  double _getMaxY() {
    final visibleSpots = _convertToSpots()
        .where((s) => s.x >= _minX && s.x <= _maxX)
        .toList();

    final double maxVisible;
    if (visibleSpots.isEmpty) {
      maxVisible = widget.stats.maxPingMs?.toDouble() ?? 150;
    } else {
      maxVisible = visibleSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    }

    final niceMax = ((maxVisible + 50) / 100).ceil() * 100.0;
    return niceMax < 100 ? 100 : niceMax;
  }

  double _xInterval() {
    final range = _maxX - _minX;
    if (widget.stats.period == StatsPeriod.day) {
      if (range <= 1) return 0.25;
      if (range <= 2) return 0.5;
      if (range <= 4) return 1;
      if (range <= 12) return 2;
      return 4;
    } else if (widget.stats.period == StatsPeriod.week) {
      if (range <= 2) return 0.5;
      return 1.0;
    } else {
      if (range <= 3) return 1;
      if (range <= 7) return 1;
      if (range <= 15) return 2;
      return 5;
    }
  }

  String _formatXValue(double value) {
    if (widget.stats.period == StatsPeriod.day) {
      final totalMinutes = (value * 60).round().clamp(0, 24 * 60);
      if (totalMinutes >= 24 * 60) return '24:00';
      final hour = totalMinutes ~/ 60;
      final minute = totalMinutes % 60;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else if (widget.stats.period == StatsPeriod.week) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[value.floor().clamp(0, 6)];
    } else {
      return '${value.floor() + 1}';
    }
  }

  String _getPeriodTitle() {
    if (widget.stats.period == StatsPeriod.week) {
      return '${DateFormat('d MMM', 'en_US').format(widget.stats.startDate)} - ${DateFormat('d MMM', 'en_US').format(widget.stats.endDate)}';
    } else if (widget.stats.period == StatsPeriod.month) {
      return DateFormat('MMMM yyyy', 'en_US').format(widget.stats.startDate);
    }
    return "";
  }

  bool get _isZoomed => (_maxX - _minX) < (_periodEnd - 0.1);

  @override
  Widget build(BuildContext context) {
    final spots = _convertToSpots();

    if (spots.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No ping data for this period',
            style: TextStyle(fontSize: 16, color: widget.mediumColor),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (widget.stats.period == StatsPeriod.day) ...[
                _TimeButton(
                  label: _formatXValue(_minX),
                  color: widget.mediumColor,
                  textColor: widget.textColor,
                  onTap: _pickFromTime,
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 14, color: widget.mediumColor),
                const SizedBox(width: 8),
                _TimeButton(
                  label: _formatXValue(_maxX),
                  color: widget.mediumColor,
                  textColor: widget.textColor,
                  onTap: _pickToTime,
                ),
              ] else ...[
                Text(
                  _getPeriodTitle(),
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
              const Spacer(),
              if (_isZoomed)
                IconButton(
                  onPressed: _resetZoom,
                  icon: Icon(
                    Icons.zoom_out_map,
                    size: 18,
                    color: widget.backColor,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerEnd,
              onPointerCancel: _onPointerEnd,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _onHorizontalDragStart,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                onHorizontalDragCancel: _onHorizontalDragCancel,
                child: LineChart(
                  key: _chartKey,
                  LineChartData(
                    minX: _minX,
                    maxX: _maxX,
                    minY: 0,
                    maxY: _getMaxY(),
                    clipData: FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 100,
                      verticalInterval: _xInterval(),
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: widget.mediumColor.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (_) => FlLine(
                        color: widget.mediumColor.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _xInterval(),
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value < _minX - 0.01 || value > _maxX + 0.01) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              _formatXValue(value),
                              style: TextStyle(
                                color: widget.mediumColor,
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 100,
                          reservedSize: _leftTitlesReservedSize,
                          getTitlesWidget: (value, meta) {
                            if (value.remainder(100).abs() > 0.001) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '${value.toInt()} ms',
                              style: TextStyle(
                                color: widget.mediumColor,
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: widget.mediumColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    lineBarsData: _buildBars(),
                    lineTouchData: LineTouchData(
                      enabled: !_isPinching && !_isDragging,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) => touchedSpots
                            .map(
                              (spot) => LineTooltipItem(
                                '${_formatXValue(spot.x)}\n${spot.y.toInt()} ms',
                                TextStyle(
                                  color: widget.cardColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  duration: Duration.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 14, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
