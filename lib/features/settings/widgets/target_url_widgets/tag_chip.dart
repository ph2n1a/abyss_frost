import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class TagChip extends StatelessWidget {
  final String label;
  final void Function() onDeleted;
  final Color avatarColor;

  const TagChip({
    super.key,
    required this.label,
    required this.onDeleted,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: appColors.backColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onDeleted: onDeleted,
      deleteIconColor: appColors.backColor,
      avatar: CircleAvatar(backgroundColor: avatarColor),
      backgroundColor: appColors.accentColor.withValues(alpha: 0.12),
      side: BorderSide(color: appColors.gray.withValues(alpha: 0.8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
