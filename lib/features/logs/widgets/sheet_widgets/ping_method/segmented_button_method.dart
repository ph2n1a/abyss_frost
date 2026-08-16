import 'package:flutter/material.dart';

class SegmentButtonPingMethodFilter extends StatelessWidget {
  final ValueNotifier<Set<String>> selectedMethods;

  const SegmentButtonPingMethodFilter({
    super.key,
    required this.selectedMethods,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: selectedMethods,
      builder: (context, methods, child) {
        return SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'Via Proxy HEAD',
              label: Text('via Proxy HEAD')
            ),
            ButtonSegment(
                value: 'Via Proxy GET',
                label: Text('via Proxy GET')
            ),
          ],
          selected: methods,
          onSelectionChanged: (selected) {
            selectedMethods.value = selected;
          },
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
          showSelectedIcon: true,
          selectedIcon: Icon(Icons.check),
        );
      },
    );
  }
}