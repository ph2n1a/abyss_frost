import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class UrlTextField extends StatefulWidget {
  final String targetUrl;
  final ValueChanged<String> targetUrlChange;

  const UrlTextField({
    super.key,
    required this.targetUrl,
    required this.targetUrlChange,
  });

  @override
  State<UrlTextField> createState() => _UrlTextFieldState();
}

class _UrlTextFieldState extends State<UrlTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.targetUrl);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant UrlTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetUrl != widget.targetUrl &&
        _controller.text != widget.targetUrl) {
      _controller.value = TextEditingValue(
        text: widget.targetUrl,
        selection: TextSelection.collapsed(offset: widget.targetUrl.length),
      );
    }
  }

  void _onTextChanged() {
    final newValue = _controller.text;
    if (newValue != widget.targetUrl) {
      widget.targetUrlChange(newValue);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return TextField(
      controller: _controller,
      style: TextStyle(
        color: appColors.backColor,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: appColors.backColor,
      decoration: InputDecoration(
        hintText: 'URL',
        hintStyle: TextStyle(
          color: appColors.backColor,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: appColors.gray.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.backColor, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
