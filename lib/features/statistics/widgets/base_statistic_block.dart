import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class BaseStatisticBlock extends StatelessWidget {
  final String label;
  final int statisticInt;
  final String statisticText;
  final IconData icon;
  final String additionalText;

  const BaseStatisticBlock({
    super.key,
    required this.label,
    required this.statisticText,
    required this.icon,
    required this.additionalText,
    required this.statisticInt,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: appColors.accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: appColors.backColor,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(7),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appColors.backColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: appColors.mainColor,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  statisticInt.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                    color: appColors.backColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  statisticText,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: appColors.backColor,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 152,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: appColors.backColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                additionalText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: appColors.mainColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
