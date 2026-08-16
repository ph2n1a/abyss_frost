import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LatencyNumberField extends StatefulWidget {
  final ValueNotifier<RangeValues> latencyRange;
  final ValueChanged<RangeValues> latencyRangeChange;
  final bool isEnd;

  const LatencyNumberField({
    super.key,
    required this.latencyRange,
    required this.latencyRangeChange,
    required this.isEnd,
  });

  @override
  State<LatencyNumberField> createState() => _LatencyNumberFieldState();
}

class _LatencyNumberFieldState extends State<LatencyNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.isEnd
          ? widget.latencyRange.value.end.round().toString()
          : widget.latencyRange.value.start.round().toString(),
    );

    _controller.addListener(() {
      final text = _controller.text;

      if (text.isEmpty) return;

      final parsedValue = double.tryParse(text);

      if (parsedValue == null) return;

      if (parsedValue > 999) {
        _controller.value = TextEditingValue(
          text: '999',
          selection: TextSelection.collapsed(offset: 3),
        );
        return;
      }

      final currentStart = widget.isEnd
          ? widget.latencyRange.value.start
          : parsedValue;
      final currentEnd = widget.isEnd
          ? parsedValue
          : widget.latencyRange.value.end;

      final safeStart = currentStart > currentEnd ? currentEnd : currentStart;
      final safeEnd = currentStart > currentEnd ? currentStart : currentEnd;

      final newLatencyRange = RangeValues(safeStart, safeEnd);

      widget.latencyRange.value = newLatencyRange;
      widget.latencyRangeChange(newLatencyRange);
    });

    widget.latencyRange.addListener(_onNotifierChanged);
  }

  void _onNotifierChanged() {
    final currentRange = widget.latencyRange.value;
    final expectedText = widget.isEnd
        ? currentRange.end.round().toString()
        : currentRange.start.round().toString();

    if (_controller.text != expectedText) {
      _controller.text = expectedText;
    }
  }

  @override
  void dispose() {
    widget.latencyRange.removeListener(_onNotifierChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        decoration: InputDecoration(
          hintText: widget.isEnd ? 'To' : 'From',
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
