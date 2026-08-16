import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class NavigationWidget extends StatelessWidget {
  final int selectedIndex;
  final List<double> scale;
  final Future<void> Function(int index) onItemTapped;

  const NavigationWidget({
    super.key,
    required this.selectedIndex,
    required this.scale,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          height: 75,
          child: Center(
            child: Container(
              width: 320,
              margin: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 0.0,
                bottom: 15.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(50),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double step = ((constraints.maxWidth - 6) - 104) / 3;
                  double topPosition = 2.5;

                  List<double> xPositions = [
                    3,
                    step + 13,
                    step * 2 + 26,
                    step * 3 + 37,
                  ];

                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(
                          left: xPositions[selectedIndex],
                          top: topPosition,
                        ),
                        height: 55,
                        width: 70,
                        decoration: BoxDecoration(
                          color: appColors.accentColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 13.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildNavButton(context, 0, Icons.home_rounded, selectedIndex == 0),
                              _buildNavButton(context, 1, Icons.stacked_bar_chart_outlined, selectedIndex == 1),
                              _buildNavButton(context, 2, Icons.terminal_outlined, selectedIndex == 2),
                              _buildNavButton(context, 3, Icons.settings, selectedIndex == 3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, int index, IconData icon, bool isSelected) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return AnimatedScale(
      scale: scale[index],
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: IconButton(
        onPressed: () => onItemTapped(index),
        icon: Icon(
          icon,
          color: appColors.backColor,
          size: 26,
        ),
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    );
  }
}