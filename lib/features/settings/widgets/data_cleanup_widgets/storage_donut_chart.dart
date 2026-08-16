import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:abyss_frost/core/database/app_database.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class StorageDonutChart extends StatefulWidget {
  final List<MonthStats> months;

  const StorageDonutChart({super.key, required this.months});

  @override
  State<StorageDonutChart> createState() => _StorageDonutChartState();
}

class _StorageDonutChartState extends State<StorageDonutChart>
    with SingleTickerProviderStateMixin {
  static const int _maxSegments = 5;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorAt(int index, int count) {
    final t = count <= 1 ? 0.0 : index / (count - 1);
    final hue = 205 - t * 115;
    return HSLColor.fromAHSL(1, hue, 0.75, 0.5).toColor();
  }

  List<_Segment> _buildSegments() {
    final months = widget.months;

    if (months.length <= _maxSegments) {
      return [
        for (int i = 0; i < months.length; i++)
          _Segment(
            months[i].monthYear,
            months[i].sizeMb,
            _colorAt(i, months.length),
          ),
      ];
    }

    final visible = months.sublist(0, _maxSegments - 1);
    final rest = months.sublist(_maxSegments - 1);
    final restValue = rest.fold<double>(0, (sum, m) => sum + m.sizeMb);

    return [
      for (int i = 0; i < visible.length; i++)
        _Segment(
          visible[i].monthYear,
          visible[i].sizeMb,
          _colorAt(i, _maxSegments),
        ),
      _Segment('Other (${rest.length})', restValue, const Color(0xFF8D939E)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    final total =
    widget.months.fold<double>(0, (sum, m) => sum + m.sizeMb);

    if (widget.months.isEmpty || total <= 0) {
      return const SizedBox.shrink();
    }

    final segments = _buildSegments();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Storage by month',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '${total.toStringAsFixed(2)} MB',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appColors.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(150, 150),
                          painter: _DonutPainter(
                            segments: segments,
                            total: total,
                            progress: Curves.easeOut
                                .transform(_controller.value),
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'MB',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: appColors.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    for (final segment in segments)
                      _LegendRow(
                        segment: segment,
                        total: total,
                        accentColor: appColors.accentColor,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final _Segment segment;
  final double total;
  final Color accentColor;

  const _LegendRow({
    required this.segment,
    required this.total,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? segment.value / total * 100 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: segment.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              segment.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment {
  final String label;
  final double value;
  final Color color;

  const _Segment(this.label, this.value, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  final double total;
  final double progress;

  _DonutPainter({
    required this.segments,
    required this.total,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final thickness = size.width * 0.16;
    final rect = (Offset.zero & size).deflate(thickness / 2);
    final gap = segments.length > 1 ? 0.03 : 0.0;

    double start = -math.pi / 2;

    for (final segment in segments) {
      final fraction = segment.value / total;
      final sweep = fraction * 2 * math.pi * progress;

      if (sweep > 0) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..color = segment.color;

        if (gap > 0 && sweep > gap) {
          canvas.drawArc(rect, start + gap / 2, sweep - gap, false, paint);
        } else {
          canvas.drawArc(rect, start, sweep, false, paint);
        }
      }

      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.total != total ||
          oldDelegate.progress != progress ||
          oldDelegate.segments != segments;
}