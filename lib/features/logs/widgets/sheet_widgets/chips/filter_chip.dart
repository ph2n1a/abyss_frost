import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class MyFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color avatarColor;
  final Widget? avatarChild;

  const MyFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.avatarColor,
    required this.avatarChild,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return FilterChip(
      label: Text(
        label,
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: appColors.mainColor,
      avatar: CircleAvatar(
        backgroundColor: avatarColor.withValues(alpha: 0.2),
        child: avatarChild,
      ),
    );
  }
}
