import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class SelectedButtonTag extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final Color color;

  const SelectedButtonTag({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: appColors.gray.withValues(alpha: 0.5),
          foregroundColor: appColors.mainColor,
          side: BorderSide(
            color: appColors.gray.withValues(alpha: 0.8),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                color: appColors.mainColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
