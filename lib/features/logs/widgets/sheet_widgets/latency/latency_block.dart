import 'package:flutter/material.dart';
import 'widgets/latency_slider.dart';
import 'widgets/latency_number_field.dart';

class LatencyBlock extends StatelessWidget {
  final ValueNotifier<RangeValues> latencyRange;
  final ValueChanged<RangeValues> latencyRangeChange;

  const LatencyBlock({
    super.key,
    required this.latencyRange,
    required this.latencyRangeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MyRangeSliderLatency(
          latencyRange: latencyRange,
          latencyRangeChange: latencyRangeChange,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: LatencyNumberField(
                latencyRange: latencyRange,
                latencyRangeChange: latencyRangeChange,
                isEnd: false,
              ),
            ),
            Expanded(
              child: LatencyNumberField(
                latencyRange: latencyRange,
                latencyRangeChange: latencyRangeChange,
                isEnd: true,
              ),
            ),
          ],
        )
      ],
    );
  }
}
