import 'package:flutter/material.dart';
import 'package:abyss_frost/core/database/app_database.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class MonthCleanupCard extends StatelessWidget {
  final MonthStats month;
  final bool isDeleting;
  final Future<bool> Function() onConfirmDelete;
  final Future<void> Function() onDelete;

  const MonthCleanupCard({
    super.key,
    required this.month,
    required this.isDeleting,
    required this.onConfirmDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Dismissible(
      key: ValueKey('month_cleanup_${month.monthYear}'),
      direction: DismissDirection.endToStart,
      resizeDuration: const Duration(milliseconds: 180),

      confirmDismiss: (_) => onConfirmDelete(),

      onDismissed: (_) {
        onDelete();
      },

      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.35),
          ),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 26,
        ),
      ),

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.gray.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 2,
            color: appColors.gray.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: appColors.backColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: appColors.backColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month.monthYear,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${month.pingCount} pings • ${month.sizeMb.toStringAsFixed(2)} MB',
                    style: TextStyle(
                      color: appColors.backColor.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isDeleting)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                onPressed: () async {
                  final confirmed = await onConfirmDelete();
                  if (confirmed) {
                    await onDelete();
                  }
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
          ],
        ),
      ),
    );
  }
}