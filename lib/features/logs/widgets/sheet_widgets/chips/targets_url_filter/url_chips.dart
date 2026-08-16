import 'package:abyss_frost/features/logs/widgets/sheet_widgets/chips/filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:abyss_frost/core/services/data/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UrlFiltersChips extends StatefulWidget {
  final ValueNotifier<List<String>> targetUrls;

  const UrlFiltersChips({
    super.key,
    required this.targetUrls,
  });

  @override
  State<UrlFiltersChips> createState() => _UrlFiltersChipsState();
}

class _UrlFiltersChipsState extends State<UrlFiltersChips> {
  final prefs = CallSharedPreferences.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: widget.targetUrls,
      builder: (context, selectedUrls, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < prefs.targetsUrl.length; i++) ...[
                Builder(
                  builder: (context) {
                    final url = prefs.targetsUrl[i];
                    final isSelected = selectedUrls.contains(url);

                    return Padding(
                      padding: EdgeInsets.only(right: i == prefs.targetsUrl.length - 1 ? 0 : 8),
                      child: MyFilterChip(
                        label: url,
                        selected: isSelected,
                        onSelected: (value) {
                          final currentList = List<String>.from(selectedUrls);
                          if (value) {
                            currentList.add(url);
                          } else {
                            currentList.remove(url);
                          }
                          widget.targetUrls.value = currentList;
                        },
                        avatarColor: Colors.transparent,
                        avatarChild: SvgPicture.asset(
                          'assets/icons/$url.svg',
                          height: 20,
                          width: 20,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}