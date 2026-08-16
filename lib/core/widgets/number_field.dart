import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class NumberField extends StatefulWidget {
  final ValueNotifier<int> number;
  final int minValue;
  final int maxValue;
  final String hintText;

  const NumberField({
    super.key,
    required this.number,
    this.minValue = 0,
    this.maxValue = 7200,
    this.hintText = "",
  });

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final TextEditingController _controller;
  bool _isUpdatingFromNotifier = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.number.value.toString(),
    );

    _controller.addListener(_onTextChanged);

    widget.number.addListener(_onNotifierChanged);
  }

  @override
  void didUpdateWidget(covariant NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      oldWidget.number.removeListener(_onNotifierChanged);
      widget.number.addListener(_onNotifierChanged);
      _controller.text = widget.number.value.toString();
    }
  }

  void _onNotifierChanged() {
    if (_isUpdatingFromNotifier) return;

    final newText = widget.number.value.toString();
    if (_controller.text != newText) {
      _isUpdatingFromNotifier = true;
      _controller.text = newText;
      _isUpdatingFromNotifier = false;
    }
  }

  void _onTextChanged() {
    if (_isUpdatingFromNotifier) return;

    final text = _controller.text;

    if (text.isEmpty) {
      return;
    }

    final value = int.tryParse(text);
    if (value == null) return;

    if (value > widget.maxValue) {
      _controller.value = TextEditingValue(
        text: widget.maxValue.toString(),
        selection: TextSelection.collapsed(
          offset: widget.maxValue.toString().length,
        ),
      );
      return;
    }

    if (value < widget.minValue) {
      return;
    }

    _isUpdatingFromNotifier = true;
    widget.number.value = value;
    _isUpdatingFromNotifier = false;
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    widget.number.removeListener(_onNotifierChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: appColors.backColor,
          ),
        ),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(widget.maxValue.toString().length),
          ],
          style: TextStyle(color: appColors.backColor),
          cursorColor: appColors.backColor,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: false,
            hintText: widget.hintText,
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: appColors.backColor,
                width: 3
              ),
            ),
            focusColor: appColors.backColor,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                width: 3,
                color: appColors.backColor,
              ),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 8,
            ),
          ),
        ),
      ),
    );
  }
}