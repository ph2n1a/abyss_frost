import 'package:flutter/material.dart';

class MyRangeSliderLatency extends StatelessWidget {
  final ValueNotifier<RangeValues> latencyRange;
  final ValueChanged<RangeValues> latencyRangeChange;

  const MyRangeSliderLatency({
    super.key,
    required this.latencyRange,
    required this.latencyRangeChange,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RangeValues>(
      valueListenable: latencyRange,
      builder: (context, value, child) {
        return RangeSlider(
          values: value,
          min: 0,
          max: 999,
          labels: RangeLabels(
            value.start.round().toString(),
            value.end.round().toString(),
          ),
          onChanged: latencyRangeChange,
        );
      },
    );
  }
}
