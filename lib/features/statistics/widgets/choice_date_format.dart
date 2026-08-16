import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChoiceDateFormat extends StatefulWidget {
  final int formatIndex;
  final ValueChanged<int> onChangedFormat;

  const ChoiceDateFormat({
    super.key,
    required this.formatIndex,
    required this.onChangedFormat
  });

  @override
  State<ChoiceDateFormat> createState() => _ChoiceDateFormatState();
}

class _ChoiceDateFormatState extends State<ChoiceDateFormat> {

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      height: 48,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: widget.formatIndex * 57,
            top: 5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 38,
              width: 55,
              decoration: BoxDecoration(
                color: appColors.accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: switch (widget.formatIndex) {
                    0 => Radius.circular(50),
                    1 => Radius.circular(5),
                    2 => Radius.circular(5),
                    _ => Radius.zero,
                  },
                  bottomLeft: switch (widget.formatIndex) {
                    0 => Radius.circular(50),
                    1 => Radius.circular(5),
                    2 => Radius.circular(5),
                    _ => Radius.zero,
                  },
                  topRight: switch (widget.formatIndex) {
                    0 => Radius.circular(5),
                    1 => Radius.circular(5),
                    2 => Radius.circular(50),
                    _ => Radius.zero,
                  },
                  bottomRight: switch (widget.formatIndex) {
                    0 => Radius.circular(5),
                    1 => Radius.circular(5),
                    2 => Radius.circular(50),
                    _ => Radius.zero,
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 2
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSegment(
                  text: "Day",
                  themeMode: ThemeMode.light,
                  appColors: appColors,
                  isSelected: widget.formatIndex == 0,
                  position: 0,
                ),
                _buildSegment(
                  text: "Week",
                  themeMode: ThemeMode.system,
                  appColors: appColors,
                  isSelected: widget.formatIndex == 1,
                  position: 1,
                ),
                _buildSegment(
                  text: "Month",
                  themeMode: ThemeMode.dark,
                  appColors: appColors,
                  isSelected: widget.formatIndex == 2,
                  position: 2,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String text,
    required bool isSelected,
    required ThemeMode themeMode,
    required AppColors appColors,
    required int position,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onChangedFormat(position);
      },
      child: Center(
        child: SizedBox(
          height: 40,
          width: 55,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: appColors.mediumColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}