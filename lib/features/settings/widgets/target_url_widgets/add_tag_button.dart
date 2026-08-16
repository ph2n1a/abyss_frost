import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class AddTagButton extends StatelessWidget {
  final void Function() onPressed;

  const AddTagButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(
          color: appColors.gray.withValues(alpha: 0.8),
          width: 1.2,
        ),
        backgroundColor: appColors.backgroundColor.withValues(alpha: 0.35),
        foregroundColor: appColors.backColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(
        'Add',
        style: TextStyle(
          color: appColors.backColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
