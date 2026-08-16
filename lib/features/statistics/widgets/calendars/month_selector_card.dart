import 'package:flutter/material.dart';
import 'package:abyss_frost/core/theme/app_colors.dart';

class MonthSelectorCard extends StatefulWidget {
  final ValueNotifier<DateTime> selectedDate;
  const MonthSelectorCard({super.key, required this.selectedDate});

  @override
  State<MonthSelectorCard> createState() => _MonthSelectorCardState();
}

class _MonthSelectorCardState extends State<MonthSelectorCard> {
  late int _displayYear;

  @override
  void initState() {
    super.initState();
    _displayYear = widget.selectedDate.value.year;
    widget.selectedDate.addListener(_updateYear);
  }

  void _updateYear() {
    if (mounted && _displayYear != widget.selectedDate.value.year) {
      setState(() => _displayYear = widget.selectedDate.value.year);
    }
  }

  @override
  void dispose() {
    widget.selectedDate.removeListener(_updateYear);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final today = DateTime.now();
    final canGoNext = _displayYear < today.year;

    return Container(
      decoration: BoxDecoration(
        color: appColors.accentColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _displayYear--),
                icon: Icon(Icons.arrow_back, color: appColors.backColor),
              ),
              Expanded(
                child: Center(
                  child: Text('$_displayYear', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: appColors.backColor)),
                ),
              ),
              IconButton(
                onPressed: canGoNext ? () => setState(() => _displayYear++) : null,
                icon: Icon(
                  Icons.arrow_forward,
                  color: canGoNext ? appColors.backColor : appColors.backColor.withOpacity(0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final isDisabled = _displayYear == today.year && index > today.month - 1;
              final isSelected = widget.selectedDate.value.year == _displayYear && widget.selectedDate.value.month == index + 1;

              return GestureDetector(
                onTap: isDisabled ? null : () {
                  widget.selectedDate.value = DateTime(_displayYear, index + 1, 1);
                },
                child: Opacity(
                  opacity: isDisabled ? 0.35 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? appColors.backColor : appColors.mediumColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index],
                      style: TextStyle(
                        color: isSelected ? appColors.mainColor : appColors.backColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}