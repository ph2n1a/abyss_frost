import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsBlock extends StatefulWidget {
  final Icon icon;
  final String header;
  final String description;
  final Widget child;

  const SettingsBlock({
    super.key,
    required this.icon,
    required this.header,
    required this.description,
    required this.child,
  });

  @override
  State<SettingsBlock> createState() => _SettingsBlockState();
}

class _SettingsBlockState extends State<SettingsBlock> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: widget.header == "Try bypass VPN" ?
          BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5)
          ) : BorderRadius.circular(15),
          color: appColors.accentColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: appColors.backColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: widget.icon
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      widget.header,
                      style: TextStyle(
                        fontSize: 18,
                        color: appColors.backColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8,
                      right: 4,
                    ),
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: appColors.mediumColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
